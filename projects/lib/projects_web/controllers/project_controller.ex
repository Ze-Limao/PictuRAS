defmodule ProjectsApiWeb.ProjectController do
  use ProjectsApiWeb, :controller

  alias ProjectsApi.Projects
  alias ProjectsApi.Projects.Project
  alias ProjectsApi.Accounts
  alias ProjectsApi.Accounts.User

  action_fallback ProjectsApiWeb.FallbackController

  def index(conn, %{"user_id" => user_id}) do
    projects = Projects.list_projects(user_id)
    render(conn, :index, projects: projects, current_user_id: user_id)
  end

  def create(conn, %{"user_id" => user_id, "project" => params}) do
    %User{} = user = Accounts.get_or_create_user(user_id)
    params = Map.put(params, "owner_id", user.id)

    with {:ok, %Project{} = project} <- Projects.create_project(params) do
      conn
      |> put_status(:created)
      |> render(:show, project: project, current_user_id: user_id)
    end
  end

  def show(conn, %{"user_id" => user_id, "id" => id}) do
    project = Projects.maybe_get_project!(id, user_id)
    render(conn, :show, project: project, current_user_id: user_id)
  end

  def update(conn, %{"id" => id, "project" => params}) do
    project = Projects.get_project!(id)

    with {:ok, %Project{} = project} <- Projects.update_project(project, params) do
      render(conn, :show, project: project, current_user_id: project.owner_id)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)

    with {:ok, %Project{}} <- Projects.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end
end
