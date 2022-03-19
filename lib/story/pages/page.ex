defmodule Story.Pages.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :description, :string
    field :slug, :string
    field :title, :string
    field :published, :boolean
    field :user_id, :id
    has_many :readings, Story.Pages.Reading
    has_many :stats, Story.Stats.Stat
    has_many :timeline_items, Story.Timelines.Item
    has_many :links, Story.Profiles.Link
    has_one :personal_information, Story.Profiles.Info

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:slug, :title, :description, :user_id, :published])
    |> validate_required([:slug, :title, :description, :user_id])
    |> unique_constraint(:slug)
    |> cast_assoc(:readings)
    |> cast_assoc(:stats)
    |> cast_assoc(:timeline_items)
    |> cast_assoc(:links)
    |> cast_assoc(:personal_information)
  end
end
