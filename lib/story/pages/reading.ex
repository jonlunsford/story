defmodule Story.Pages.Reading do
  use Ecto.Schema
  import Ecto.Changeset

  schema "readings" do
    field :author, :string
    field :description, :string
    field :title, :string
    field :url, :string
    belongs_to :page, Story.Pages.Page
    belongs_to :user, Story.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:author, :description, :title, :url, :page_id, :user_id])
    |> validate_required([:title, :user_id])
    |> foreign_key_constraint(:user_id, name: :readings_user_id_fkey)
  end
end
