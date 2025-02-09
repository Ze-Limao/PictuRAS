defmodule ProjectsApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ProjectsApiWeb, :controller

  defguard is_404(reason) when reason in [:not_found]
  defguard is_500(reason) when reason in [:internal_server_error]

  ## These clauses handles errors returned by Ecto's insert/update/delete.

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ProjectsApiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {0, nil}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: ProjectsApiWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, reason}) when is_404(reason) do
    conn
    |> put_status(:not_found)
    |> put_view(json: ProjectsApiWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, reason}) when is_500(reason) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(json: ProjectsApiWeb.ErrorJSON)
    |> render(:"500")
  end
end
