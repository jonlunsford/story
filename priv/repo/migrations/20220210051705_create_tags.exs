defmodule Story.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:tags, [:name])
  end
end
