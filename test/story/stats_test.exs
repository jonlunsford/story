defmodule Story.StatsTest do
  use Story.DataCase

  alias Story.Stats

  describe "stats" do
    alias Story.Stats.Stat

    import Story.StatsFixtures

    @invalid_attrs %{description: nil, title: nil, url: nil, value: nil}

    test "list_stats/0 returns all stats" do
      stat = stat_fixture()
      assert Enum.member?(Stats.list_stats(), stat)
    end

    test "get_stat!/1 returns the stat with given id" do
      stat = stat_fixture()
      assert Stats.get_stat!(stat.id) == stat
    end

    test "create_stat/1 with valid data creates a stat" do
      valid_attrs = %{description: "some description", title: "some title", url: "some url", value: 120.5}

      assert {:ok, %Stat{} = stat} = Stats.create_stat(valid_attrs)
      assert stat.description == "some description"
      assert stat.title == "some title"
      assert stat.url == "some url"
      assert stat.value == 120.5
    end

    test "create_stat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stats.create_stat(@invalid_attrs)
    end

    test "create_and_tag_stat/2 with valid data returns the info" do
      result = Story.Stats.create_and_tag_stat(%{description: "Foo"}, [%{name: "Biz"}, %{name: "Baz"}])

      assert %Stat{description: "Foo", tags: [%Story.Tags.Tag{}, %Story.Tags.Tag{}]} = result
    end

    test "update_stat/2 with valid data updates the stat" do
      stat = stat_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", url: "some updated url", value: 456.7}

      assert {:ok, %Stat{} = stat} = Stats.update_stat(stat, update_attrs)
      assert stat.description == "some updated description"
      assert stat.title == "some updated title"
      assert stat.url == "some updated url"
      assert stat.value == 456.7
    end

    test "update_stat/2 with invalid data returns error changeset" do
      stat = stat_fixture()
      assert {:error, %Ecto.Changeset{}} = Stats.update_stat(stat, @invalid_attrs)
      assert stat == Stats.get_stat!(stat.id)
    end

    test "delete_stat/1 deletes the stat" do
      stat = stat_fixture()
      assert {:ok, %Stat{}} = Stats.delete_stat(stat)
      assert_raise Ecto.NoResultsError, fn -> Stats.get_stat!(stat.id) end
    end

    test "change_stat/1 returns a stat changeset" do
      stat = stat_fixture()
      assert %Ecto.Changeset{} = Stats.change_stat(stat)
    end
  end
end
