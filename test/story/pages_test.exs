defmodule Story.PagesTest do
  use Story.DataCase

  alias Story.Pages

  setup do
    user = Story.AccountsFixtures.user_fixture()

    {:ok, %{user_id: user.id}}
  end

  describe "readings" do
    alias Story.Pages.Reading

    import Story.PagesFixtures

    @invalid_attrs %{author: nil, description: nil, title: nil, url: nil}

    test "list_readings/0 returns all readings" do
      reading = reading_fixture()
      assert Enum.member?(Pages.list_readings(), reading)
    end

    test "get_reading!/1 returns the reading with given id" do
      reading = reading_fixture()
      assert Pages.get_reading!(reading.id) == reading
    end

    test "create_reading/1 with valid data creates a reading", %{user_id: user_id} do
      valid_attrs = %{author: "some author", description: "some description", title: "some title", url: "some url", user_id: user_id}

      assert {:ok, %Reading{} = reading} = Pages.create_reading(valid_attrs)
      assert reading.author == "some author"
      assert reading.description == "some description"
      assert reading.title == "some title"
      assert reading.url == "some url"
    end

    test "create_reading/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pages.create_reading(@invalid_attrs)
    end

    test "update_reading/2 with valid data updates the reading", %{user_id: user_id} do
      reading = reading_fixture()
      update_attrs = %{author: "some updated author", description: "some updated description", title: "some updated title", url: "some updated url", user_id: user_id}

      assert {:ok, %Reading{} = reading} = Pages.update_reading(reading, update_attrs)
      assert reading.author == "some updated author"
      assert reading.description == "some updated description"
      assert reading.title == "some updated title"
      assert reading.url == "some updated url"
    end

    test "update_reading/2 with invalid data returns error changeset" do
      reading = reading_fixture()
      assert {:error, %Ecto.Changeset{}} = Pages.update_reading(reading, @invalid_attrs)
      assert reading == Pages.get_reading!(reading.id)
    end

    test "delete_reading/1 deletes the reading" do
      reading = reading_fixture()
      assert {:ok, %Reading{}} = Pages.delete_reading(reading)
      assert_raise Ecto.NoResultsError, fn -> Pages.get_reading!(reading.id) end
    end

    test "change_reading/1 returns a reading changeset" do
      reading = reading_fixture()
      assert %Ecto.Changeset{} = Pages.change_reading(reading)
    end
  end
end
