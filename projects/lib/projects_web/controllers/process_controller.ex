defmodule ProjectsApiWeb.ProcessController do
  use ProjectsApiWeb, :controller

  alias ProjectsApi.Projects
  alias ProjectsApi.Projects.Project
  alias ProjectsApi.Orchestrator

  action_fallback ProjectsApiWeb.FallbackController

  def process(conn, %{"id" => id, "tools" => tools}) do
    project = Projects.get_project!(id)

    if Project.can_be_processed?(project) && length(tools) != 0 do
      with {:ok, _tools} <- Projects.override_tools(tools, project.id) do
        process_project(project)

        conn
        |> put_status(:accepted)
        |> json(%{
          message: "Project started processing"
        })
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{
        errors: %{
          detail:
            "Project cannot be processed. Maybe it's already being processed? Or you didn't upload any images or selected any tools?"
        }
      })
    end
  end

  defp process_project(project) do
    Task.start(fn ->
      Orchestrator.Server.process_project(project.id)
    end)
  end
end
