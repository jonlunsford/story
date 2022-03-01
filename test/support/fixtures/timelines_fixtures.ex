defmodule Story.TimelinesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Story.Timelines` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    user = Story.AccountsFixtures.user_fixture()

    {:ok, item} =
      attrs
      |> Enum.into(%{
        start_date: ~N[2022-02-09 05:03:00],
        end_date: ~N[2022-02-09 05:03:00],
        current_position: false,
        description: "some description",
        img: "some img",
        location: "some location",
        order_by: 42,
        title: "some title",
        type: "some type",
        url: "some url",
        user_id: user.id,
        page_id: Story.PagesFixtures.page_fixture(%{use_id: user.id}).id
      })
      |> Story.Timelines.create_item()

    item
  end
end
