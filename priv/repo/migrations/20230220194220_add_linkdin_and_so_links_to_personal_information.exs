defmodule Story.Repo.Migrations.AddLinkdinAndSoLinksToPersonalInformation do
  use Ecto.Migration

  def change do
    alter table(:personal_information) do
      add :linkedin, :string
      add :stack_overflow, :string
    end
  end
end
