defmodule Story.StatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Story.Stats` context.
  """

  @doc """
  Generate a stat.
  """
  def stat_fixture(attrs \\ %{}) do
    {:ok, stat} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title",
        url: "some url",
        value: 120.5,
        user_id: Story.AccountsFixtures.user_fixture().id
      })
      |> Story.Stats.create_stat()

    stat
  end
end
