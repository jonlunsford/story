defmodule Story.Repo.Migrations.AddCurrentBooleanToTimelineItemsTable do
  use Ecto.Migration

  def change do
    alter table("timeline_items") do
      add :current_position, :boolean, default: false
    end
  end
end
