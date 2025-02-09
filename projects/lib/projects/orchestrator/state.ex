defmodule ProjectsApi.Orchestrator.State do
  @moduledoc """
  State module for the Orchestrator server. It runs as an Agent.
  """
  # TODO: Keep the state on Redis instead of using an Agent
  use Agent

  alias ProjectsApi.Projects.Image
  alias ProjectsApi.Projects

  require Logger

  @keys ~w(channel projects pending)a

  @enforce_keys @keys
  defstruct @keys

  def new(chan) do
    state = %__MODULE__{
      channel: chan,
      # project_id => project
      projects: %{},
      # project_id => {[pending messages], total acked messages}
      pending: %{}
    }

    {:ok, state} = Agent.start_link(fn -> state end, name: __MODULE__)
    Logger.info("Orchestrator state (via Agent) started")
    state
  end

  def channel(state), do: Agent.get(state, &Map.get(&1, :channel))

  ## Projects

  @doc """
  Adds a new project to the state. Bearing in mind that only
  the initial images will be added to the project's inputs.

  If a project with the same id already exists, it will be replaced.
  """
  def add_project(state, project_id, images, tools) do
    finals =
      images
      |> Enum.filter(&Image.initial?/1)
      |> Enum.map(&build_final_image(project_id, &1))

    project = %{
      length: length(tools),
      completion: 0,
      inputs: finals,
      outputs: [],
      tools: tools
    }

    projects = Agent.get(state, &Map.get(&1, :projects))
    projects = Map.put(projects, project_id, project)
    Agent.update(state, &Map.put(&1, :projects, projects))

    pending = Agent.get(state, &Map.get(&1, :pending))
    pending = Map.put(pending, project_id, {[], 0})
    Agent.update(state, &Map.put(&1, :pending, pending))

    Logger.info("Project with id #{project_id} added to the state")
  end

  # Copy existing image to the final location
  # and return the new image
  # Same location, but with -final suffix
  defp build_final_image(project_id, image) do
    extension = Path.extname(image.uri)

    new_uri =
      Path.join(
        Path.dirname(image.uri),
        Path.basename(image.uri, extension) <> "-final" <> extension
      )

    File.cp!(image.uri, new_uri)
    Projects.upsert_final_image!(project_id, new_uri)
  end

  @doc """
  Removes a project from the state. Called when the project
  processing is fully finished.

  This will also remove any pending messages related to the project.
  """
  def clean_project(state, project_id) do
    projects = Agent.get(state, &Map.get(&1, :projects))
    projects = Map.delete(projects, project_id)
    Agent.update(state, &Map.put(&1, :projects, projects))

    pending = Agent.get(state, &Map.get(&1, :pending))
    pending = Map.delete(pending, project_id)
    Agent.update(state, &Map.put(&1, :pending, pending))

    Logger.info("Project with id #{project_id} removed from the state")
  end

  @doc """
  Given an id, returns the project from the state.
  """
  def find_project(state, project_id) do
    projects = Agent.get(state, &Map.get(&1, :projects))
    Map.get(projects, project_id)
  end

  @doc """
  Returns the project's completion status.

  A project is finished if all the tools have been applied.
  """
  def project_fully_finished?(state, project_id) do
    project = find_project(state, project_id)
    project.completion == 100
  end

  @doc """
  Returns `true` if the current project step (or tool) was completed.

  A tool is said to be completed whenever the total acked messages
  is equal to the total number of images (number of published messages).
  """
  def project_step_finished?(state, project_id) do
    project = find_project(state, project_id)
    count_acked_messages(state, project_id) == length(project.inputs)
  end

  @doc """
  Gets the next tool to apply on the project.

  The next tool is calculated based on the project's completion
  and the total number of tools in the project.

  For example, if the project has 9 tools and the completion is at 44.(4),
  the next tool will be at index (truncated) 44.(4) / 11.(1) = 4. This is
  based on the idea that the completion is always a percentage of the total
  project length, incremented by a step of 100 / length(tools).
  """
  def next_tool(state, project_id) do
    project = find_project(state, project_id)

    step = step(project.length)
    index = project.completion / step
    Enum.at(project.tools, trunc(index))
  end

  @doc """
  Increases the project's completion by a step.

  The step is calculated based on the project's length.
  Refer to `next_tool/2` for more information.
  """
  def increase_completion(state, project_id) do
    project = find_project(state, project_id)

    step = step(project.length)
    project = Map.update!(project, :completion, &(&1 + step))

    projects = Agent.get(state, &Map.get(&1, :projects))
    projects = Map.put(projects, project_id, project)
    Agent.update(state, &Map.put(&1, :projects, projects))
  end

  @doc """
  Returns the project's completion.
  """
  def completion(state, project_id) do
    project = find_project(state, project_id)
    project.completion
  end

  defp step(length), do: 100 / length

  ## Pending messages

  def new_pending_message(state, mid, project_id) do
    pending = Agent.get(state, &Map.get(&1, :pending))
    pending = Map.update!(pending, project_id, &new_pending_message_internal(&1, mid))
    Agent.update(state, &Map.put(&1, :pending, pending))
  end

  defp new_pending_message_internal({messages, acked}, mid), do: {[mid | messages], acked}

  def ack_pending_message(state, project_id, mid) do
    pending = Agent.get(state, &Map.get(&1, :pending))
    pending = Map.update!(pending, project_id, &ack_pending_message_internal(&1, mid))
    Agent.update(state, &Map.put(&1, :pending, pending))
  end

  defp ack_pending_message_internal({messages, acked}, mid) do
    {Enum.reject(messages, &(&1 == mid)), acked + 1}
  end

  def find_pending_message(state, mid) do
    pending = Agent.get(state, &Map.get(&1, :pending))
    maybe_message = Enum.find(pending, fn {_, {messages, _}} -> Enum.member?(messages, mid) end)

    case maybe_message do
      nil -> nil
      {project_id, _} -> {project_id, mid}
    end
  end

  def count_acked_messages(state, project_id) do
    pending = Agent.get(state, &Map.get(&1, :pending))
    {_, acked} = Map.get(pending, project_id)
    acked
  end

  def clean_pending_messages(state, project_id) do
    pending = Agent.get(state, &Map.get(&1, :pending))
    pending = Map.put(pending, project_id, {[], 0})
    Agent.update(state, &Map.put(&1, :pending, pending))
  end

  ## Images

  def new_output_image(state, project_id, uri) do
    project = find_project(state, project_id)
    project = Map.update!(project, :outputs, &(&1 ++ [%{uri: uri}]))

    projects = Agent.get(state, &Map.get(&1, :projects))
    projects = Map.put(projects, project_id, project)
    Agent.update(state, &Map.put(&1, :projects, projects))
  end

  @doc """
  Moves the project's outputs to inputs.

  This is called whenever a tool finishes processing the images.
  """
  def from_outputs_to_inputs(state, project_id) do
    project = find_project(state, project_id)

    project = Map.put(project, :inputs, project.outputs)
    project = Map.put(project, :outputs, [])

    projects = Agent.get(state, &Map.get(&1, :projects))
    projects = Map.put(projects, project_id, project)
    Agent.update(state, &Map.put(&1, :projects, projects))
  end
end
