defmodule ProjectsApi.Accounts.Guest do
  use ProjectsApi, :schema

  alias ProjectsApi.Accounts.User
  alias ProjectsApi.Projects.Project

  @required_fields ~w(user_id project_id)a

  schema "guests" do
    belongs_to :user, User
    belongs_to :project, Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(guest, attrs) do
    guest
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
