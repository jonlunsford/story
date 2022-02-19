defmodule Story.Timelines.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timeline_items" do
    field :start_date, :naive_datetime
    field :end_date, :naive_datetime
    field :current_position, :boolean
    field :description, :string
    field :img, :string
    field :content_img, :string
    field :location, :string
    field :order_by, :integer
    field :title, :string
    field :type, :string
    field :url, :string
    field :user_id, :id
    many_to_many :tags, Story.Tags.Tag, join_through: Story.Tags.TimelineItemTag
    belongs_to :page, Story.Pages.Page

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :start_date,
      :end_date,
      :current_position,
      :description,
      :content_img,
      :img,
      :location,
      :order_by,
      :title,
      :type,
      :url
    ])
    |> validate_required([:start_date, :title])
  end
end
