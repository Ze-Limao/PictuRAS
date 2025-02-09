defmodule ProjectsApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias ProjectsApi.Projects.Project
  alias ProjectsApi.Accounts.Guest

  @required_fields ~w(email)a

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string

    has_many :projects, Project, foreign_key: :owner_id
    has_many :guests, Guest

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_unique_email()
  end

  defp validate_unique_email(changeset) do
    changeset
    |> unsafe_validate_unique(:email, ProjectsApi.Repo)
    |> unique_constraint(:email)
  end
end
