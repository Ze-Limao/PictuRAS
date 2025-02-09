defmodule UsersApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use UsersApiWeb, :controller

  defguard is_404(reason) when reason in [:not_found]
  defguard is_401(reason) when reason in [:unauthorized, :invalid_credentials]

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: UsersApiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, reason}) when is_404(reason) do
    conn
    |> put_status(:not_found)
    |> put_view(json: UsersApiWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, reason}) when is_401(reason) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: UsersApiWeb.ErrorJSON)
    |> render(:"401")
  end
end
