defmodule ProjectsApi.Repo.Migrations.CreateTools do
  use Ecto.Migration

  def change do
    create table(:tools, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :procedure, :string, null: false
      add :parameters, :map
      add :position, :integer, null: false

      add :project_id, references(:projects, type: :binary_id),
        null: false,
        on_delete: :delete_all

      timestamps(type: :utc_datetime)
    end
  end
end
