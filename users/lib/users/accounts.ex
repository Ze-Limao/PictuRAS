defmodule UsersApi.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use UsersApi, :context

  alias UsersApi.Accounts.User

  @doc """
  Authenticates a user by email and password.

  If there is no user or the user doesn't have a password, we call
  `Argon2.no_user_verify/0` to prevent timing attacks.
  """
  def authenticate_user(email, password) do
    get_user(email: email)
    |> maybe_authenticate_user(password)
  end

  defp maybe_authenticate_user(nil, _) do
    Argon2.no_user_verify()
    {:error, :invalid_credentials}
  end

  defp maybe_authenticate_user(user, password) do
    if Argon2.verify_pass(password, user.hashed_password) do
      {:ok, user}
    else
      {:error, :invalid_credentials}
    end
  end

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(email: "foo@example.com")
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(attrs) when is_list(attrs) do
    Repo.get_by(User, attrs)
  end

  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user by email.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user_by_email!(email) do
    Repo.get_by!(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(%User{}, %{field: value})
      {:ok, %User{}}

      iex> update_user(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end
end
