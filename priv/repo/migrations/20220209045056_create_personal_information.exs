defmodule Story.Repo.Migrations.CreatePersonalInformation do
  use Ecto.Migration

  def change do
    create table(:personal_information) do
      add :statement, :text
      add :job_title, :string
      add :name, :string
      add :location, :string
      add :favorite_editor, :string
      add :first_computer, :string
      add :picture_url, :string
      add :user_id, references(:users, on_delete: :delete_all)
      belongs_to, :page, Story.Pages.Page

      timestamps()
    end

    create index(:personal_information, [:user_id])
  end
end
