defmodule Story.Repo.Migrations.AddTechnologiesToTimelineItems do
  use Ecto.Migration

  def change do
    alter table(:timeline_items) do
      add :technologies, :text
    end
  end
end
