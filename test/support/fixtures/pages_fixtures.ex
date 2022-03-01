defmodule Story.PagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Story.Pages` context.
  """

  def time_stamp do
    {:ok, time} = DateTime.now("Etc/UTC")
    DateTime.to_unix(time)
  end
  def unique_slug, do: "user#{System.unique_integer()}-my-#{time_stamp()}-slug"

  def page_fixture(attrs \\ %{}) do
    {:ok, page} =
      attrs
      |> Enum.into(%{
        description: "some defines",
        slug: unique_slug(),
        title: "some title",
        user_id: Story.AccountsFixtures.user_fixture().id
      })
      |> Story.Pages.create_page()

    page
  end

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
        url: "some url",
        user_id: Story.AccountsFixtures.user_fixture().id
      })
      |> Story.Pages.create_reading()

    reading
  end
end
