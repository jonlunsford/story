defmodule Story.Repo.Migrations.ChangeDateColumnsInTimelineItemsTable do
  use Ecto.Migration

  def change do
    alter table("timeline_items") do
      add :end_date, :naive_datetime
    end

    rename table("timeline_items"), :date, to: :start_date
  end
end
