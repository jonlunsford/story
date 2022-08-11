defmodule Story.Profiles.Info do
  use Ecto.Schema
  import Ecto.Changeset

  alias Story.Profiles.Info
  alias Story.Tags.Tag

  schema "personal_information" do
    field :favorite_editor, :string
    field :first_computer, :string
    field :job_title, :string
    field :location, :string
    field :name, :string
    field :picture_url, :string
    field :statement, :string
    field :github, :string
    field :twitter, :string
    field :website, :string
    field :technologies_expert, :string
    field :technologies_desired, :string
    field :technologies_undesired, :string
    belongs_to :user, Story.Accounts.User
    belongs_to :page, Story.Pages.Page

    many_to_many :tags, Story.Tags.Tag,
      join_through: Story.Tags.InfoTag,
      join_keys: [personal_information_id: :id, tag_id: :id]

    timestamps()
  end

  @doc false
  def changeset(info, attrs) do
    info
    |> copy_tags()
    |> cast(attrs, [
      :statement,
      :job_title,
      :name,
      :location,
      :favorite_editor,
      :first_computer,
      :picture_url,
      :github,
      :twitter,
      :website,
      :technologies_expert,
      :technologies_desired,
      :technologies_undesired,
      :user_id,
      :page_id
    ])
    |> validate_required([:name, :user_id])
    |> cast_assoc(:tags)
  end

  def copy_tags(%Info{technologies_desired: value, tags: [%Tag{} | _]} = info)
      when is_nil(value) do

    info
    |> Map.put(:technologies_desired, Enum.map_join(info.tags, ", ", &(&1.name)))
  end

  def copy_tags(info), do: info
end
