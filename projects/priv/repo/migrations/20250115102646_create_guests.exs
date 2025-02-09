defmodule ProjectsApi.Repo.Migrations.CreateGuests do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext"

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :email, :citext

      timestamps(type: :utc_datetime)
    end

    create table(:guests, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, type: :binary_id),
        null: false,
        on_delete: :delete_all

      add :user_id, references(:users, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:guests, [:project_id, :user_id])

    alter table(:projects) do
      add :owner_id, references(:users, type: :binary_id), null: false
    end
  end
end
