defmodule UsersApiWeb.InternalUserController do
  use UsersApiWeb, :controller

  alias UsersApi.Accounts
  alias UsersApi.Accounts.User

  action_fallback UsersApiWeb.FallbackController

  def show(conn, %{"email" => email}) do
    with %User{} = user <- Accounts.get_user_by_email!(email) do
      conn
      |> put_status(:ok)
      |> json(%{
        id: user.id
      })
    end
  end
end
