defmodule UsersApiWeb.Plugs.SetCurrentUser do
  @moduledoc """
  Plug that assigns the current user to the connection.

  It assumes the user was already authenticated by the
  gateway and gets it from a populated header.
  """
  alias UsersApi.Accounts

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    from_header =
      get_req_header(conn, "x-user-id")
      |> List.first()
      |> sanitize()

    if !is_nil(get_current_user(from_header)) do
      assign(conn, :current_user, get_current_user(from_header))
    else
      not_found(conn)
    end
  end

  defp get_current_user(id) do
    case Accounts.get_user(id) do
      nil -> nil
      user -> user
    end
  end

  defp not_found(conn) do
    body = Jason.encode!(%{error: %{detail: "Not found"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, body)
    |> halt()
  end

  defp sanitize(id), do: String.replace(id, ~r/"/, "")
end
