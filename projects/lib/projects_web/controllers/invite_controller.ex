defmodule ProjectsApiWeb.InviteController do
  use ProjectsApiWeb, :controller

  alias ProjectsApi.Projects
  alias ProjectsApi.Accounts.{User, Guest}
  alias ProjectsApi.Accounts
  alias ProjectsApiWeb.InternalRequester

  action_fallback ProjectsApiWeb.FallbackController

  def invite(conn, %{"user_id" => owner_id, "id" => project_id, "email" => email}) do
    project = Projects.get_project!(project_id)

    with {:ok, %{"id" => user_id}} <- InternalRequester.user_exists?(email) do
      if user_id == owner_id do
        conn
        |> put_status(400)
        |> json(%{
          errors: %{
            detail: "Owner cannot invite themselves to their own project"
          }
        })
      else
        %User{} = user = Accounts.get_or_create_user(user_id)

        with {:ok, %Guest{}} <- Projects.invite_user(user, project) do
          Accounts.update_user(user, %{email: email})

          conn
          |> put_status(:created)
          |> json(%{
            message: "User successfully invited to the project"
          })
        end
      end
    end
  end

  def revoke(conn, %{"user_id" => owner_id, "id" => project_id, "email" => email}) do
    project = Projects.get_project!(project_id)

    with {:ok, %{"id" => user_id}} <- InternalRequester.user_exists?(email) do
      if user_id == owner_id do
        conn
        |> put_status(400)
        |> json(%{
          errors: %{
            detail: "Owner cannot revoke themselves from their own project"
          }
        })
      else
        %User{} = user = Accounts.get_or_create_user(user_id)

        with {1, nil} <- Projects.revoke_user(user, project) do
          conn
          |> put_status(:ok)
          |> json(%{
            message: "User successfully revoked from the project"
          })
        end
      end
    end
  end
end
