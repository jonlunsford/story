defmodule Story.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :slug, :string
      add :title, :string
      add :description, :text
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:pages, [:slug])
    create index(:pages, [:user_id])
  end
end
