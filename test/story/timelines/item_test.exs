# test/story/timelines/item_test.exs
defmodule Story.Timelines.ItemTest do
  use Story.DataCase

  alias Story.Timelines.Item
  alias Story.Tags.Tag

  test "changeset/2 returns NaiveDateTime" do
    attrs = %{
      "page_id" => "1",
      "user_id" => "1",
      "title" => "Foo",
      "tags" => [],
      "start_date" => %{"month" => "1", "year" => "2022"},
      "order_by" => %{"month" => "1", "year" => "2022"},
      "end_date" => %{"month" => "1", "year" => "2023"}
    }

    changeset =
      %Item{}
      |> Item.changeset(attrs)

    assert changeset.valid?
  end

  test "changeset/2 handles nil dates" do
    attrs = %{
      "page_id" => "1",
      "user_id" => "1",
      "title" => "Foo",
      "start_date" => nil,
      "order_by" => nil,
      "end_date" => nil
    }

    changeset =
      %Item{}
      |> Item.changeset(attrs)

    refute changeset.valid?
  end

  test "copy_tags/1 merges existing tags with technologies" do
    tags = [%Tag{name: "foo"}, %Tag{name: "bar"}]
    item = %Item{tags: tags, title: "name"}
    result = Item.copy_tags(item)

    assert result.technologies == "foo, bar"
  end

  test "copy_tags/1 does not merge tags if technologies is populated" do
    tags = [%Tag{name: "foo"}, %Tag{name: "bar"}]
    item = %Item{tags: tags, technologies: "biz, baz", title: "name"}
    result = Item.copy_tags(item)

    assert result.technologies == "biz, baz"
  end
end
