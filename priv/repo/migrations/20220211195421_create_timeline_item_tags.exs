defmodule Story.Repo.Migrations.CreateTimelineItemTags do
  use Ecto.Migration

  def change do
    create table(:timeline_item_tags) do
      add :timeline_item_id, references(:timeline_items, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :nothing)

      timestamps()
    end

    create index(:timeline_item_tags, [:timeline_item_id])
    create index(:timeline_item_tags, [:tag_id])
  end
end
