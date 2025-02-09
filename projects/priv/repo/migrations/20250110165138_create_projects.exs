defmodule ProjectsApi.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :state, :string, default: "idle"
      add :completion, :integer, default: 0

      timestamps(type: :utc_datetime)
    end
  end
end
