defmodule Story.Tags.StatTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stat_tags" do

    field :stat_id, :id
    field :tag_id, :id

    timestamps()
  end

  @doc false
  def changeset(stat_tag, attrs) do
    stat_tag
    |> cast(attrs, [:stat_id, :tag_id])
    |> validate_required([:stat_id, :tag_id])
  end
end
