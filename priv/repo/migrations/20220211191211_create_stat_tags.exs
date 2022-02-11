defmodule Story.Repo.Migrations.CreateStatTags do
  use Ecto.Migration

  def change do
    create table(:stat_tags) do
      add :stat_id, references(:stats, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :nothing)

      timestamps()
    end

    create index(:stat_tags, [:stat_id])
    create index(:stat_tags, [:tag_id])
  end
end
