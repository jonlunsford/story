defmodule Story.Repo.Migrations.AddPageIdToPsersonalInformation do
  use Ecto.Migration

  def change do
    alter table(:personal_information) do
      add :page_id, references(:pages, on_delete: :nothing)
    end

    create index(:personal_information, [:page_id])
  end
end
