defmodule Story.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :url, :string
      add :text, :string
      add :active, :boolean, default: true, null: false
      add :page_id, references(:pages, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:links, [:page_id])
    create index(:links, [:user_id])
  end
end
