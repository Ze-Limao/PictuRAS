defmodule ProjectsApiWeb.ToolController do
  use ProjectsApiWeb, :controller

  alias ProjectsApi.Projects.Tool

  action_fallback ProjectsApiWeb.FallbackController

  def index(conn, _params) do
    tools = Tool.list_available_tools()

    conn
    |> put_status(:ok)
    |> json(%{data: tools})
  end
end
