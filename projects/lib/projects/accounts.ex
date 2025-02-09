defmodule ProjectsApi.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use ProjectsApi, :context

  alias ProjectsApi.Accounts.User

  @doc """
  Get a user by its id or create a new one if it doesn't exist.
  """
  def get_or_create_user(user_id) do
    case Repo.get(User, user_id) do
      nil ->
        %User{id: user_id}
        |> Repo.insert!()

      user ->
        user
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update!()
  end
end
