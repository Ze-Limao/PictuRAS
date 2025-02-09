defmodule ProjectsApiWeb.Plugs.EnsureSelf do
  @moduledoc """
  This plug is used to ensure that the user in the connection parameters is the same
  as the user in the connection headers.

  It assumes the connection header was populated by the api gateway, which
  already verified the user's identity.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    from_header =
      get_req_header(conn, "x-user-id")
      |> List.first()
      |> sanitize()

    from_params = conn.params["user_id"]

    if from_header == from_params do
      conn
    else
      forbidden(conn)
    end
  end

  defp forbidden(conn) do
    body = Jason.encode!(%{errors: %{detail: "Forbidden"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(403, body)
    |> halt()
  end

  defp sanitize(id), do: String.replace(id, ~r/"/, "")
end
