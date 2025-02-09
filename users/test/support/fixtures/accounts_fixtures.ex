defmodule UsersApi.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UsersApi.Accounts` context.
  """

  alias UsersApi.Accounts

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "foo@example.com",
        name: "Foo Bar",
        password: "password1234"
      })
      |> Accounts.create_user()

    user
  end
end
