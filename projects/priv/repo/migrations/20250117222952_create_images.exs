defmodule ProjectsApi.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :uri, :string, null: false
      add :type, :string, default: "initial"

      add :project_id, references(:projects, type: :binary_id),
        null: false,
        on_delete: :delete_all

      timestamps(type: :utc_datetime)
    end
  end
end
