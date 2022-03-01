defmodule Story.Profiles.Info do
  use Ecto.Schema
  import Ecto.Changeset

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
      :user_id,
      :page_id
    ])
    |> validate_required([:name, :user_id])
    |> cast_assoc(:tags)
  end
end
