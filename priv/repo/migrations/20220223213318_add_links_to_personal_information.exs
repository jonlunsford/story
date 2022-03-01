defmodule Story.Repo.Migrations.AddLinksToPersonalInformation do
  use Ecto.Migration

  def change do
    alter table(:personal_information) do
      add :github, :string
      add :twitter, :string
      add :website, :string
    end
  end
end
