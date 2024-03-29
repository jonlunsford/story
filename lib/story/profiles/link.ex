defmodule Story.Profiles.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :active, :boolean, default: true
    field :text, :string
    field :url, :string
    belongs_to :user, Story.Accounts.User
    belongs_to :page, Story.Pages.Page

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:url, :text, :active, :user_id, :page_id])
    |> validate_required([:url, :text, :user_id, :page_id])
  end
end
