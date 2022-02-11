defmodule Story.Repo.Migrations.CreateReadings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :author, :string
      add :description, :text
      add :title, :string
      add :url, :string
      add :page_id, references(:pages, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:readings, [:page_id])
    create index(:readings, [:user_id])
  end
end
