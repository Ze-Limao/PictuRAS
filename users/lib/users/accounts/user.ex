defmodule UsersApi.Accounts.User do
  use UsersApi, :schema

  @required_fields ~w(name email password)a
  @optional_fields ~w(type)a

  @types ~w(normal premium)a
  @default_type :normal

  schema "users" do
    field :name, :string
    field :email, :string
    field :type, Ecto.Enum, values: @types, default: @default_type

    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_inclusion(:type, @types)
    |> check_required(user.hashed_password)
    |> validate_email()
    |> validate_password()
  end

  @doc """
  A simple changeset for updating the user.
  """
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_inclusion(:type, @types)
  end

  defp check_required(%Ecto.Changeset{} = changeset, hash) do
    case hash do
      nil ->
        changeset
        |> validate_required(@required_fields)

      _ ->
        changeset
        |> validate_required(@required_fields -- [:password])
    end
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> validate_unique_email()
  end

  defp validate_unique_email(changeset) do
    changeset
    |> unsafe_validate_unique(:email, UsersApi.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    |> hash_password()
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Argon2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end
