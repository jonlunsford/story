defmodule Story.Profiles.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :active, :boolean, default: true
    field :text, :string
    field :url, :string
    field :page_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:url, :text, :active])
    |> validate_required([:url, :text])
  end
end
