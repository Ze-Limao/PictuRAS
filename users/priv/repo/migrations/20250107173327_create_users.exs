defmodule UsersApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext"

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :email, :citext, null: false
      add :type, :string, default: "normal"

      add :hashed_password, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
