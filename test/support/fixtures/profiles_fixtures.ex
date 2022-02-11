defmodule Story.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Story.Profiles` context.
  """

  @doc """
  Generate a info.
  """
  def info_fixture(attrs \\ %{}) do
    {:ok, info} =
      attrs
      |> Enum.into(%{
        favorite_editor: "some favorite_editor",
        first_computer: "some first_computer",
        job_title: "some job_title",
        location: "some location",
        name: "some name",
        picture_url: "some picture_url",
        statement: "some statement"
      })
      |> Story.Profiles.create_info()

    info
  end

  @doc """
  Generate a unique page slug.
  """
  def unique_page_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a link.
  """
  def link_fixture(attrs \\ %{}) do
    {:ok, link} =
      attrs
      |> Enum.into(%{
        active: true,
        text: "some text",
        url: "some url"
      })
      |> Story.Profiles.create_link()

    link
  end
end
