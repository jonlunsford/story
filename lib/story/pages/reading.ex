defmodule Story.Pages.Reading do
  use Ecto.Schema
  import Ecto.Changeset

  schema "readings" do
    field :author, :string
    field :description, :string
    field :title, :string
    field :url, :string
    field :page_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:author, :description, :title, :url, :page_id, :user_id])
    |> validate_required([:title])
  end
end
