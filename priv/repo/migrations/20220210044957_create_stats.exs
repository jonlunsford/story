defmodule Story.Repo.Migrations.CreateStats do
  use Ecto.Migration

  def change do
    create table(:stats) do
      add :value, :float
      add :title, :string
      add :description, :text
      add :url, :string
      add :img, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :page_id, references(:pages, on_delete: :nothing)

      timestamps()
    end

    create index(:stats, [:user_id])
    create index(:stats, [:page_id])
  end
end
