defmodule UsersApi.AccountsTest do
  use UsersApi.DataCase

  alias UsersApi.Accounts

  describe "users" do
    alias UsersApi.Accounts.User

    import UsersApi.AccountsFixtures

    @invalid_attrs %{name: nil, email: nil, password: nil}

    test "authenticate_user/2 returns user when credentials are valid" do
      user = user_fixture()
      assert {:ok, ^user} = Accounts.authenticate_user(user.email, "password1234")
    end

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user(user.id) == user
    end

    test "get_user/1 by email returns the user with given email" do
      user = user_fixture()
      assert Accounts.get_user(email: user.email) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "Foo Bar", email: "foo@example.com", password: "password1234"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "Foo Bar"
      assert user.email == "foo@example.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end
  end
end
