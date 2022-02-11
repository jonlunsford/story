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
    field :user_id, :id
    many_to_many :tags, Story.Tags.Tag, join_through: Story.Tags.InfoTag

    timestamps()
  end

  @doc false
  def changeset(info, attrs) do
    info
    |> cast(attrs, [:statement, :job_title, :name, :location, :favorite_editor, :first_computer, :picture_url])
    |> validate_required([:name])
    |> cast_assoc(:tags)
  end
end
