defmodule Story.TagsTest do
  use Story.DataCase

  alias Story.Tags

  describe "tags" do
    alias Story.Tags.Tag

    import Story.TagsFixtures

    @invalid_attrs %{active: nil, name: nil}

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Enum.member?(Tags.list_tags(), tag)
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Tags.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{active: true, name: "some name"}

      assert {:ok, %Tag{} = tag} = Tags.create_tag(valid_attrs)
      assert tag.active == true
      assert tag.name == "some name"
    end

    test "create_or_find_tag/1 with a new tag creates a new record" do
      valid_attrs = %{active: true, name: "some name"}
      tag = Tags.create_or_find_tag(valid_attrs)

      assert tag.name == "some name"
    end

    test "create_or_find_tag/1 with an existing tags returns an existing record" do
      valid_attrs = %{active: true, name: "some name"}

      assert {:ok, %Tag{} = existing_tag} = Tags.create_tag(valid_attrs)

      found_existing_tag = Tags.create_or_find_tag(valid_attrs)

      assert found_existing_tag.id == existing_tag.id
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tags.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      update_attrs = %{active: false, name: "some updated name"}

      assert {:ok, %Tag{} = tag} = Tags.update_tag(tag, update_attrs)
      assert tag.active == false
      assert tag.name == "some updated name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Tags.update_tag(tag, @invalid_attrs)
      assert tag == Tags.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Tags.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Tags.change_tag(tag)
    end
  end

  describe "personal_information_tags" do
    alias Story.Tags.InfoTag

    import Story.ProfilesFixtures
    import Story.TagsFixtures

    setup do
      tag = tag_fixture()
      info = info_fixture()
      {:ok, %{tag_id: tag.id, info_id: info.id}}
    end

    test "list_personal_information_tags/0 returns all personal_information_tags", %{tag_id: tag_id, info_id: info_id} do
      info_tag = info_tag_fixture(tag_id: tag_id, personal_information_id: info_id)
      assert Enum.member?(Tags.list_personal_information_tags(), info_tag)
    end

    test "get_info_tag!/1 returns the info_tag with given id", %{tag_id: tag_id, info_id: info_id} do
      info_tag = info_tag_fixture(tag_id: tag_id, personal_information_id: info_id)
      assert Tags.get_info_tag!(info_tag.id) == info_tag
    end

    test "create_info_tag/1 with valid data creates a info_tag", %{tag_id: tag_id, info_id: info_id} do
      valid_attrs = %{tag_id: tag_id, personal_information_id: info_id}

      assert {:ok, %InfoTag{} = _info_tag} = Tags.create_info_tag(valid_attrs)
    end

    test "create_info_tag/1 with invalid data returns error changeset", %{tag_id: tag_id, info_id: info_id} do
      assert {:error, %Ecto.Changeset{}} = Tags.create_info_tag(%{tag_id: tag_id, info_id: info_id})
    end

    test "update_hnfo_tag/2 with valid data updates the info_tag", %{tag_id: tag_id, info_id: info_id} do
      info_tag = info_tag_fixture(tag_id: tag_id, personal_information_id: info_id)
      update_attrs = %{}

      assert {:ok, %InfoTag{} = _info_tag} = Tags.update_info_tag(info_tag, update_attrs)
    end

    test "update_info_tag/2 with invalid data returns error changeset", %{tag_id: tag_id, info_id: info_id} do
      info_tag = info_tag_fixture(tag_id: tag_id, personal_information_id: info_id)
      assert {:error, %Ecto.Changeset{}} = Tags.update_info_tag(info_tag, %{tag_id: nil, info_id: nil})
      assert info_tag == Tags.get_info_tag!(info_tag.id)
    end

    test "delete_info_tag/1 deletes the info_tag", %{tag_id: tag_id, info_id: info_id} do
      info_tag = info_tag_fixture(tag_id: tag_id, personal_information_id: info_id)
      assert {:ok, %InfoTag{}} = Tags.delete_info_tag(info_tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_info_tag!(info_tag.id) end
    end

    test "change_info_tag/1 returns a info_tag changeset", %{tag_id: tag_id, info_id: info_id} do
      info_tag = info_tag_fixture(tag_id: tag_id, personal_information_id: info_id)
      assert %Ecto.Changeset{} = Tags.change_info_tag(info_tag)
    end
  end

  describe "stat_tags" do
    alias Story.Tags.StatTag

    import Story.TagsFixtures
    import Story.StatsFixtures

    @invalid_attrs %{stat_id: nil, tag_id: nil}

    setup do
      tag = tag_fixture()
      stat = stat_fixture()
      {:ok, %{tag_id: tag.id, stat_id: stat.id}}
    end

    test "list_stat_tags/0 returns all stat_tags", %{tag_id: tag_id, stat_id: stat_id} do
      stat_tag = stat_tag_fixture(tag_id: tag_id, stat_id: stat_id)
      assert Enum.member?(Tags.list_stat_tags(), stat_tag)
    end

    test "get_stat_tag!/1 returns the stat_tag with given id", %{tag_id: tag_id, stat_id: stat_id} do
      stat_tag = stat_tag_fixture(tag_id: tag_id, stat_id: stat_id)
      assert Tags.get_stat_tag!(stat_tag.id) == stat_tag
    end

    test "create_stat_tag/1 with valid data creates a stat_tag", %{tag_id: tag_id, stat_id: stat_id} do
      valid_attrs = %{tag_id: tag_id, stat_id: stat_id}

      assert {:ok, %StatTag{} = _stat_tag} = Tags.create_stat_tag(valid_attrs)
    end

    test "create_stat_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tags.create_stat_tag(@invalid_attrs)
    end

    test "update_stat_tag/2 with valid data updates the stat_tag", %{tag_id: tag_id, stat_id: stat_id} do
      stat_tag = stat_tag_fixture(tag_id: tag_id, stat_id: stat_id)
      update_attrs = %{}

      assert {:ok, %StatTag{} = _stat_tag} = Tags.update_stat_tag(stat_tag, update_attrs)
    end

    test "update_stat_tag/2 with invalid data returns error changeset", %{tag_id: tag_id, stat_id: stat_id} do
      stat_tag = stat_tag_fixture(tag_id: tag_id, stat_id: stat_id)
      assert {:error, %Ecto.Changeset{}} = Tags.update_stat_tag(stat_tag, @invalid_attrs)
      assert stat_tag == Tags.get_stat_tag!(stat_tag.id)
    end

    test "delete_stat_tag/1 deletes the stat_tag", %{tag_id: tag_id, stat_id: stat_id} do
      stat_tag = stat_tag_fixture(tag_id: tag_id, stat_id: stat_id)
      assert {:ok, %StatTag{}} = Tags.delete_stat_tag(stat_tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_stat_tag!(stat_tag.id) end
    end

    test "change_stat_tag/1 returns a stat_tag changeset", %{tag_id: tag_id, stat_id: stat_id} do
      stat_tag = stat_tag_fixture(tag_id: tag_id, stat_id: stat_id)
      assert %Ecto.Changeset{} = Tags.change_stat_tag(stat_tag)
    end
  end

  describe "timeline_item_tags" do
    alias Story.Tags.TimelineItemTag

    import Story.TagsFixtures
    import Story.TimelinesFixtures

    @invalid_attrs %{tag_id: nil, timeline_item_id: nil}

    setup do
      tag = tag_fixture()
      item = item_fixture()
      {:ok, %{tag_id: tag.id, item_id: item.id}}
    end

    test "list_timeline_item_tags/0 returns all timeline_item_tags", %{tag_id: tag_id, item_id: item_id} do
      timeline_item_tag = timeline_item_tag_fixture(tag_id: tag_id, timeline_item_id: item_id)
      assert Enum.member?(Tags.list_timeline_item_tags(), timeline_item_tag)
    end

    test "get_timeline_item_tag!/1 returns the timeline_item_tag with given id", %{tag_id: tag_id, item_id: item_id} do
      timeline_item_tag = timeline_item_tag_fixture(tag_id: tag_id, timeline_item_id: item_id)
      assert Tags.get_timeline_item_tag!(timeline_item_tag.id) == timeline_item_tag
    end

    test "create_timeline_item_tag/1 with valid data creates a timeline_item_tag", %{tag_id: tag_id, item_id: item_id} do
      valid_attrs = %{tag_id: tag_id, timeline_item_id: item_id}

      assert {:ok, %TimelineItemTag{} = _timeline_item_tag} = Tags.create_timeline_item_tag(valid_attrs)
    end

    test "create_timeline_item_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tags.create_timeline_item_tag(@invalid_attrs)
    end

    test "update_timeline_item_tag/2 with valid data updates the timeline_item_tag", %{tag_id: tag_id, item_id: item_id} do
      timeline_item_tag = timeline_item_tag_fixture(tag_id: tag_id, timeline_item_id: item_id)
      update_attrs = %{}

      assert {:ok, %TimelineItemTag{} = _timeline_item_tag} = Tags.update_timeline_item_tag(timeline_item_tag, update_attrs)
    end

    test "update_timeline_item_tag/2 with invalid data returns error changeset", %{tag_id: tag_id, item_id: item_id} do
      timeline_item_tag = timeline_item_tag_fixture(tag_id: tag_id, timeline_item_id: item_id)
      assert {:error, %Ecto.Changeset{}} = Tags.update_timeline_item_tag(timeline_item_tag, @invalid_attrs)
      assert timeline_item_tag == Tags.get_timeline_item_tag!(timeline_item_tag.id)
    end

    test "delete_timeline_item_tag/1 deletes the timeline_item_tag", %{tag_id: tag_id, item_id: item_id} do
      timeline_item_tag = timeline_item_tag_fixture(tag_id: tag_id, timeline_item_id: item_id)
      assert {:ok, %TimelineItemTag{}} = Tags.delete_timeline_item_tag(timeline_item_tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_timeline_item_tag!(timeline_item_tag.id) end
    end

    test "change_timeline_item_tag/1 returns a timeline_item_tag changeset", %{tag_id: tag_id, item_id: item_id} do
      timeline_item_tag = timeline_item_tag_fixture(tag_id: tag_id, timeline_item_id: item_id)
      assert %Ecto.Changeset{} = Tags.change_timeline_item_tag(timeline_item_tag)
    end
  end
end
