defmodule Story.PagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Story.Pages` context.
  """

  @doc """
  Generate a reading.
  """
  def reading_fixture(attrs \\ %{}) do
    {:ok, reading} =
      attrs
      |> Enum.into(%{
        author: "some author",
        description: "some description",
        title: "some title",
        url: "some url"
      })
      |> Story.Pages.create_reading()

    reading
  end
end
