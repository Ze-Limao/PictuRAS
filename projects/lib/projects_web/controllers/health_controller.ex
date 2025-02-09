defmodule ProjectsApiWeb.HealthController do
  use ProjectsApiWeb, :controller

  @app Mix.Project.config()[:app]
  @version Mix.Project.config()[:version]

  def health(conn, _params) do
    conn
    |> json(%{app: @app, version: @version})
  end
end
