# test/story/timelines/item_test.exs
defmodule Story.Timelines.ItemTest do
  use Story.DataCase

  alias Story.Timelines.Item

  test "changeset/2 returns NaiveDateTime" do
    attrs = %{
      "page_id" => "1",
      "user_id" => "1",
      "title" => "Foo",
      "start_date" => %{"month" => "1", "year" => "2022"},
      "end_date" => %{"month" => "1", "year" => "2023"}
    }

    changeset =
      %Item{}
      |> Item.changeset(attrs)

    assert changeset.valid?
  end
end
