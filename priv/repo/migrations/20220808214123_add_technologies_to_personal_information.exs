defmodule Story.Repo.Migrations.AddTechnologiesToPersonalInformation do
  use Ecto.Migration

  def change do
    alter table(:personal_information) do
      add :technologies_expert, :text
      add :technologies_desired, :text
      add :technologies_undesired, :text
    end
  end
end
