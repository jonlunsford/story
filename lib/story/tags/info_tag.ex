defmodule Story.Tags.InfoTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "personal_information_tags" do

    field :personal_information_id, :id
    field :tag_id, :id

    timestamps()
  end

  @doc false
  def changeset(info_tag, attrs) do
    info_tag
    |> cast(attrs, [:personal_information_id, :tag_id])
    |> validate_required([:personal_information_id, :tag_id])
  end
end
