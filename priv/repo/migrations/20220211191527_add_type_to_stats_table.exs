defmodule Story.Repo.Migrations.AddTypeToStatsTable do
  use Ecto.Migration

  def change do
    alter table("stats") do
      add :type, :string
    end
  end
end
