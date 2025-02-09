defmodule ProjectsApiWeb.Plugs.VerifyProjectOwnership do
  @moduledoc """
  This plug is responsible for verifying if the user has
  access to the project resource.

  If the received `role` is `owner`, the plug will verify if
  the user is the owner of the project. If the received `role`
  is `guest`, the plug will verify if the user is a guest of
  the project or the owner of the project.
  """
  import Plug.Conn

  alias ProjectsApi.Projects

  def init(opts), do: opts

  def call(conn, role) do
    id = conn.params["id"]

    if !is_nil(id) do
      case Projects.get_project!(id) do
        nil ->
          not_found(conn)

        project ->
          user_id = conn.params["user_id"]
          verify_association(project, user_id, role, conn)
      end
    else
      conn
    end
  end

  defp verify_association(project, user_id, :owner, conn) do
    if is_owner?(project, user_id) do
      conn
    else
      forbidden(conn)
    end
  end

  defp verify_association(project, user_id, :guest, conn) do
    if is_owner?(project, user_id) || is_guest?(project, user_id) do
      conn
    else
      forbidden(conn)
    end
  end

  defp is_owner?(project, user_id), do: project.owner_id == user_id

  defp is_guest?(project, user_id) do
    ids = project.guests |> Enum.map(& &1.user_id)
    user_id in ids
  end

  defp not_found(conn) do
    body = Jason.encode!(%{errors: %{detail: "Not found"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, body)
    |> halt()
  end

  defp forbidden(conn) do
    body = Jason.encode!(%{errors: %{detail: "Forbidden"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(403, body)
    |> halt()
  end
end
