defmodule ProjectsApi.Orchestrator.Server do
  @moduledoc """
  Orchestrator server responsible for managing all
  the ongoing project's processing tasks.

  This server is simply a GenServer that will keep track
  of a global state and orchestrate the processing of
  images (in a project) via communication with RabbitMQ.
  """
  use GenServer
  use AMQP

  alias ProjectsApi.Projects
  alias ProjectsApi.Projects.Tool
  alias ProjectsApi.Orchestrator.{Notifier, State}

  require Logger

  @exchange_name "picturas.tools"
  @results_queue_name "results"

  ## Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def process_project(project_id) do
    case Projects.get_project(project_id) do
      nil ->
        # TODO: Send error back through websockets
        Logger.error("Project with id #{project_id} not found")

      project ->
        GenServer.cast(__MODULE__, {:process_project, project_id, project.images, project.tools})
    end
  end

  ## Server (callbacks)

  @impl true
  def init(_opts) do
    chan = message_queue_connect()
    message_queue_setup(chan)

    {:ok, State.new(chan)}
  end

  @impl true
  def handle_cast({:process_project, project_id, images, tools}, state) do
    State.add_project(state, project_id, images, tools)
    Projects.update_project_state(project_id, %{state: "processing"})

    Logger.info("Processing project with id #{project_id}")

    # Start processing the first tool
    process_next_tool(state, project_id)

    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, state) do
    payload = Jason.decode!(payload)
    handle_response_message(state, payload)

    # Message is only acked after it's processed
    # guaranteeing that the message is not lost
    # if the server crashes before processing it
    :ok = Basic.ack(State.channel(state), tag)
    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_consume_ok, _}, state) do
    Logger.info("Server is ready to consume messages")
    {:noreply, state}
  end

  defp handle_response_message(state, %{"status" => "success"} = response) do
    mid = response["correlationId"]

    case State.find_pending_message(state, mid) do
      nil ->
        Logger.error(
          "Received a success response for an unknown message with id #{response["messageId"]}"
        )

      {project_id, mid} ->
        Logger.info(
          "Received a success response for pending message #{mid} within project #{project_id}"
        )

        State.new_output_image(state, project_id, response["output"]["imageURI"])
        State.ack_pending_message(state, project_id, mid)

        if State.project_step_finished?(state, project_id) do
          Logger.info("Project #{project_id} finished processing a step")

          State.increase_completion(state, project_id)
          State.from_outputs_to_inputs(state, project_id)

          Notifier.notify_project_step_finished(project_id)

          maybe_process_next_tool(state, project_id)
        else
          Logger.info("There are still pending messages for project #{project_id}")
        end
    end
  end

  # TODO: Send error back through websockets
  defp handle_response_message(state, %{"status" => "error"} = response) do
    mid = response["correlationId"]

    # TODO: Print exact error sent by the tool?
    case State.find_pending_message(state, mid) do
      nil ->
        Logger.error(
          "Received an error response for an unknown message with id #{response["messageId"]}"
        )

      {project_id, mid} ->
        Logger.info(
          "Received an error response for pending message #{mid} within project #{project_id}"
        )

        State.clean_project(state, project_id)
        Projects.update_project_state(project_id, %{state: "failed"})
    end
  end

  ## Processing helpers

  defp process_next_tool(state, project_id) do
    tool = State.next_tool(state, project_id)
    project = State.find_project(state, project_id)

    project.inputs
    |> Enum.each(fn image ->
      mid = Ecto.UUID.generate()
      encoded_message = build_request_message(mid, tool, image)
      publish_message(State.channel(state), tool, encoded_message)
      State.new_pending_message(state, mid, project_id)
    end)

    Logger.info("Tool #{tool.procedure} started processing on project #{project_id}")
  end

  # TODO: Update state on websockets
  defp maybe_process_next_tool(state, project_id) do
    if State.project_fully_finished?(state, project_id) do
      Notifier.notify_project_fully_finished(project_id)

      State.clean_project(state, project_id)
      Projects.update_project_state(project_id, %{completion: 100})

      Logger.info("Project #{project_id} finished processing")
    else
      State.clean_pending_messages(state, project_id)
      Projects.update_project_state(project_id, %{completion: State.completion(state, project_id)})

      Logger.info("Processing next tool for project #{project_id}")
      process_next_tool(state, project_id)
    end
  end

  defp build_request_message(mid, tool, image) do
    %{
      messageId: mid,
      timestamp: current_iso8601(),
      procedure: tool.procedure,
      parameters: build_apply_parameters(tool, image)
    }
    |> Jason.encode!()
  end

  defp build_apply_parameters(tool, image) do
    %{
      inputImageURI: image.uri,
      outputImageURI: image.uri
    }
    |> Map.merge(tool.parameters || %{})
  end

  defp current_iso8601, do: DateTime.utc_now() |> DateTime.to_iso8601()

  defp publish_message(chan, tool, encoded_message) do
    :ok =
      Basic.publish(
        chan,
        @exchange_name,
        "requests.#{tool.procedure}",
        encoded_message
      )
  end

  ## Setup helpers

  defp message_queue_connect do
    # Proper connection is done automatically via config
    # (check under `config/config.exs` file)
    {:ok, chan} = AMQP.Application.get_channel()

    Logger.info("RabbitMQ connection established")
    chan
  end

  defp message_queue_setup(chan) do
    tools = Tool.list_available_prodecures()

    :ok = Exchange.declare(chan, @exchange_name, :direct, durable: true)

    {:ok, %{queue: results_queue}} = Queue.declare(chan, @results_queue_name)
    :ok = Queue.bind(chan, results_queue, @exchange_name, routing_key: @results_queue_name)
    Basic.consume(chan, @results_queue_name, self())

    Logger.info("RabbitMQ exchange setup")

    Enum.each(tools, fn tool ->
      name = "#{tool}-requests"
      routing_key = "requests.#{tool}"

      {:ok, %{queue: queue}} = Queue.declare(chan, name)
      :ok = Queue.bind(chan, queue, @exchange_name, routing_key: routing_key)
    end)

    Logger.info("RabbitMQ tools queues setup")
  end
end
