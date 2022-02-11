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
    field :page_id, :id
    many_to_many :tags, Story.Tags.Tag, join_through: Story.Tags.StatTag

    timestamps()
  end

  @doc false
  def changeset(stat, attrs) do
    stat
    |> cast(attrs, [:value, :title, :description, :url, :img, :type])
    |> validate_required([:description])
  end
end
