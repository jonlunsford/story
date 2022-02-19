defmodule Story.Repo.Migrations.AddContentImageToTimelineItems do
  use Ecto.Migration

  def change do
    alter table("timeline_items") do
      add :content_img, :string
    end
  end
end
