defmodule Story.TimelinesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Story.Timelines` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
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
        url: "some url"
      })
      |> Story.Timelines.create_item()

    item
  end
end
