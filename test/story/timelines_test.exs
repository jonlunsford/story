defmodule Story.TimelinesTest do
  use Story.DataCase

  alias Story.Timelines

  setup do
    user = Story.AccountsFixtures.user_fixture()
    page = Story.PagesFixtures.page_fixture(%{user_id: user.id})

    {:ok, page_id: page.id, user_id: user.id}
  end

  describe "timeline_items" do
    alias Story.Timelines.Item

    import Story.TimelinesFixtures

    @invalid_attrs %{
      start_date: nil,
      end_date: nil,
      current_position: false,
      description: nil,
      img: nil,
      location: nil,
      order_by: nil,
      title: nil,
      type: nil,
      url: nil
    }

    test "list_timeline_items/0 returns all timeline_items" do
      item = item_fixture()
      assert Enum.member?(Timelines.list_timeline_items(), item)
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Timelines.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item", %{user_id: user_id, page_id: page_id} do
      valid_attrs = %{
        start_date: ~N[2022-02-09 05:03:00],
        description: "some description",
        img: "some img",
        location: "some location",
        order_by: 42,
        title: "some title",
        type: "some type",
        url: "some url",
        user_id: user_id,
        page_id: page_id
      }

      assert {:ok, %Item{} = item} = Timelines.create_item(valid_attrs)
      assert item.start_date == ~N[2022-02-09 05:03:00]
      assert item.description == "some description"
      assert item.img == "some img"
      assert item.location == "some location"
      assert item.order_by == 42
      assert item.title == "some title"
      assert item.type == "some type"
      assert item.url == "some url"
    end

    test "create_and_tag_item/2 with valid data returns the item", %{
      user_id: user_id,
      page_id: page_id
    } do
      result =
        Timelines.create_and_tag_item(
          %{
            start_date: ~N[2022-09-09 00:00:00],
            title: "Foo",
            user_id: user_id,
            page_id: page_id
          },
          [
            %{name: "Biz"},
            %{name: "Baz"}
          ]
        )

      assert %Item{start_date: _, title: "Foo", tags: [%Story.Tags.Tag{}, %Story.Tags.Tag{}]} =
               result
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timelines.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()

      update_attrs = %{
        start_date: ~N[2022-02-10 05:03:00],
        description: "some updated description",
        img: "some updated img",
        location: "some updated location",
        order_by: 43,
        title: "some updated title",
        type: "some updated type",
        url: "some updated url"
      }

      assert {:ok, %Item{} = item} = Timelines.update_item(item, update_attrs)
      assert item.start_date == ~N[2022-02-10 05:03:00]
      assert item.description == "some updated description"
      assert item.img == "some updated img"
      assert item.location == "some updated location"
      assert item.order_by == 43
      assert item.title == "some updated title"
      assert item.type == "some updated type"
      assert item.url == "some updated url"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Timelines.update_item(item, @invalid_attrs)
      assert item == Timelines.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Timelines.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Timelines.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Timelines.change_item(item)
    end
  end
end
