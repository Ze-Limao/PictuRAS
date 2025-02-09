defmodule ProjectsApiWeb.ProjectJSON do
  alias ProjectsApi.Projects.Project

  alias ProjectsApi.Projects.{Image, Tool}
  alias ProjectsApi.Accounts.Guest

  @doc """
  Renders a list of projects.
  """
  def index(%{projects: projects, current_user_id: current_user_id}) do
    %{data: for(project <- projects, do: data(project, current_user_id, :index))}
  end

  @doc """
  Renders a single project.
  """
  def show(%{project: project, current_user_id: current_user_id}) do
    %{data: data(project, current_user_id, :show)}
  end

  defp data(%Project{} = project, current_user_id, :index) do
    default(project)
    |> Map.merge(maybe_images(project, :index))
    |> Map.merge(maybe_guests(project, current_user_id, :index))
  end

  defp data(%Project{} = project, current_user_id, :show) do
    default(project)
    |> Map.merge(maybe_images(project, :show))
    |> Map.merge(maybe_tools(project))
    |> Map.merge(maybe_guests(project, current_user_id, :show))
  end

  defp default(project) do
    %{
      id: project.id,
      name: project.name,
      state: project.state,
      completion: project.completion,
      owner_id: project.owner_id,
      created_at: project.inserted_at
    }
  end

  defp maybe_guests(project, current_user_id, :index) when current_user_id == project.owner_id do
    if is_list(project.guests) do
      %{guest_count: length(project.guests)}
    else
      %{}
    end
  end

  defp maybe_guests(_project, _current_user_id, :index), do: %{}

  defp maybe_guests(project, current_user_id, :show) when current_user_id == project.owner_id do
    if is_list(project.guests) do
      %{guests: Enum.map(project.guests, &guest/1)}
    else
      %{guests: []}
    end
  end

  defp maybe_guests(_project, _current_user_id, :show), do: %{}

  defp guest(%Guest{} = guest) do
    %{
      id: guest.user.id,
      email: guest.user.email
    }
  end

  defp maybe_images(project, :index) do
    if is_list(project.images) and length(project.images) > 0 do
      %{
        image_count: Enum.count(project.images, &Image.initial?/1),
        thumbnail: List.first(project.images).id
      }
    else
      %{image_count: 0}
    end
  end

  defp maybe_images(project, :show) do
    if is_list(project.images) and length(project.images) > 0 do
      %{
        images: Enum.map(project.images, &image/1)
      }
    else
      %{images: []}
    end
  end

  defp image(%Image{} = image) do
    %{
      id: image.id,
      type: image.type
    }
  end

  defp maybe_tools(project) do
    if is_list(project.tools) and length(project.tools) > 0 do
      tools = Tool.order_by_position(project.tools)
      %{tools: Enum.map(tools, &tool/1)}
    else
      %{tools: []}
    end
  end

  defp tool(%Tool{} = tool) do
    %{
      procedure: tool.procedure,
      parameters: tool.parameters,
      position: tool.position
    }
  end
end
