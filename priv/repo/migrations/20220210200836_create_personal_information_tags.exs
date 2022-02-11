defmodule Story.Repo.Migrations.CreatePersonalInformationTags do
  use Ecto.Migration

  def change do
    create table(:personal_information_tags) do
      add :personal_information_id, references(:personal_information, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :nothing)

      timestamps()
    end

    create index(:personal_information_tags, [:personal_information_id])
    create index(:personal_information_tags, [:tag_id])
  end
end
