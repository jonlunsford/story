defmodule Story.Pages.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :description, :string
    field :slug, :string
    field :title, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:slug, :title, :description])
    |> validate_required([:slug, :title, :description])
    |> unique_constraint(:slug)
  end
end
