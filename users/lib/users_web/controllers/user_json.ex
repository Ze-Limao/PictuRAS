defmodule UsersApiWeb.UserJSON do
  alias UsersApi.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def me(%{user: user}) do
    %{data: data(user)}
  end

  @doc """
  Renders a single user and its authentication token.

  Commonly used in login operations.
  """
  def auth(%{user: user, token: token}) do
    %{data: data(user), token: token}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      type: user.type
    }
  end
end
