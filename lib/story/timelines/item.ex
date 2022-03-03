defmodule Story.Timelines.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timeline_items" do
    field :start_date, :naive_datetime
    field :end_date, :naive_datetime
    field :order_by, :naive_datetime
    field :current_position, :boolean
    field :description, :string
    field :img, :string
    field :content_img, :string
    field :location, :string
    field :title, :string
    field :type, :string
    field :url, :string
    belongs_to :user, Story.Accounts.User
    belongs_to :page, Story.Pages.Page

    many_to_many :tags, Story.Tags.Tag, join_through: Story.Tags.TimelineItemTag,
      join_keys: [timeline_item_id: :id, tag_id: :id]

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    attrs = transform_start_date(attrs)
    attrs = transform_end_date(attrs)

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
      :url,
      :page_id,
      :user_id
    ])
    |> validate_required([:start_date, :title, :user_id, :page_id])
  end

  def transform_start_date(%{"start_date" => date} = attrs) do
    Map.put(attrs, "start_date", map_to_date(date))
  end

  def transform_start_date(attrs), do: attrs

  def transform_end_date(%{"end_date" => date} = attrs) do
    Map.put(attrs, "end_date", map_to_date(date))
  end

  def transform_end_date(attrs), do: attrs

  defp map_to_date(%{"month" => month, "year" => year}) do
    month = String.to_integer(month)
    year = String.to_integer(year)

    {:ok, datetime} = NaiveDateTime.new(year, month, 1, 0,0,0)

    datetime
  end

  defp map_to_date(_), do: nil
end
