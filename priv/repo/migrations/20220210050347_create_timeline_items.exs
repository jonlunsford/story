defmodule Story.Repo.Migrations.CreateTimelineItems do
  use Ecto.Migration

  def change do
    create table(:timeline_items) do
      add :date, :naive_datetime
      add :description, :text
      add :img, :string
      add :location, :string
      add :order_by, :naive_datetime
      add :title, :string
      add :type, :string
      add :url, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :page_id, references(:pages, on_delete: :nothing)

      timestamps()
    end

    create index(:timeline_items, [:user_id])
    create index(:timeline_items, [:page_id])
  end
end
