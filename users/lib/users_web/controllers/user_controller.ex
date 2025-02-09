defmodule UsersApiWeb.UserController do
  use UsersApiWeb, :controller

  alias UsersApi.Accounts
  alias UsersApi.Accounts.User
  alias UsersApiWeb.Authentication

  action_fallback UsersApiWeb.FallbackController

  @doc """
  Registers a new user, by creating it at the database and returning the user data.
  """
  def register(conn, %{"user" => params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(params) do
      conn
      |> put_status(:created)
      |> render(:me, user: user)
    end
  end

  @doc """
  Logs in a user and returns the user and a freshly generated token.
  """
  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, %User{} = user} <- Accounts.authenticate_user(email, password) do
      {:ok, token, _claims} = Authentication.Guardian.encode_and_sign(user)

      conn
      |> put_status(:ok)
      |> render(:auth, user: user, token: token)
    end
  end

  @doc """
  Assumes that user is authenticated, by successfully
  passing the authentication plug.

  Renders the user present in the connection assigns (`conn.assigns`).
  """
  def me(conn, _) do
    user = conn.assigns[:current_user]

    conn
    |> put_status(:ok)
    |> render(:me, user: user)
  end

  @doc """
  Updates the current user with the given parameters.
  """
  def update(conn, %{"user" => params}) do
    user = conn.assigns[:current_user]

    with {:ok, %User{} = user} <- Accounts.update_user(user, params) do
      conn
      |> put_status(:ok)
      |> render(:me, user: user)
    end
  end
end
