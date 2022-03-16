defmodule Story.Tags.TimelineItemTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timeline_item_tags" do

    field :timeline_item_id, :id
    field :tag_id, :id

    timestamps()
  end

  @doc false
  def changeset(timeline_item_tag, attrs) do
    timeline_item_tag
    |> cast(attrs, [:timeline_item_id, :tag_id])
    |> validate_required([:timeline_item_id, :tag_id])
  end
end
