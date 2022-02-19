defmodule Story.Repo.Migrations.AddSlugToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :slug, :string
    end

    create unique_index(:users, [:slug])
  end
end
