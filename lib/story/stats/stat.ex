defmodule Story.Stats.Stat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stats" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :img, :string
    field :type, :string
    field :value, :float
    field :user_id, :id
    belongs_to :page, Story.Pages.Page
    many_to_many :tags, Story.Tags.Tag, join_through: Story.Tags.StatTag

    timestamps()
  end

  @doc false
  def changeset(stat, attrs) do
    stat
    |> cast(attrs, [:value, :title, :description, :url, :img, :type, :user_id, :page_id])
    |> validate_required([:description, :user_id])
    |> cast_assoc(:tags)
  end
end
