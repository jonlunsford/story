defmodule Story.Repo.Migrations.AddPublishedToPages do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add :published, :boolean, default: true, null: false
    end
  end
end
