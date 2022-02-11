defmodule Story.TagsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Story.Tags` context.
  """

  @doc """
  Generate a unique tag name.
  """
  def unique_tag_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        active: true,
        name: unique_tag_name()
      })
      |> Story.Tags.create_tag()

    tag
  end

  @doc """
  Generate a info_tag.
  """
  def info_tag_fixture(attrs \\ %{}) do
    {:ok, info_tag} =
      attrs
      |> Enum.into(%{

      })
      |> Story.Tags.create_info_tag()

    info_tag
  end

  @doc """
  Generate a stat_tag.
  """
  def stat_tag_fixture(attrs \\ %{}) do
    {:ok, stat_tag} =
      attrs
      |> Enum.into(%{

      })
      |> Story.Tags.create_stat_tag()

    stat_tag
  end

  @doc """
  Generate a timeline_item_tag.
  """
  def timeline_item_tag_fixture(attrs \\ %{}) do
    {:ok, timeline_item_tag} =
      attrs
      |> Enum.into(%{

      })
      |> Story.Tags.create_timeline_item_tag()

    timeline_item_tag
  end
end
