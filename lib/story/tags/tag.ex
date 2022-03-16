defmodule Story.Tags.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :active, :boolean, default: true
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :active])
    |> validate_required([:name, :active])
    |> unique_constraint(:name)
  end
end
