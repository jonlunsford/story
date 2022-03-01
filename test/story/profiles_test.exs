defmodule Story.ProfilesTest do
  use Story.DataCase

  alias Story.Profiles
  alias Story.Tags.Tag

  setup do
    user = Story.AccountsFixtures.user_fixture()
    page = Story.PagesFixtures.page_fixture(%{user_id: user.id})

    {:ok, %{user_id: user.id, page_id: page.id}}
  end

  describe "personal_information" do
    alias Story.Profiles.Info

    import Story.ProfilesFixtures

    @invalid_attrs %{
      favorite_editor: nil,
      first_computer: nil,
      job_title: nil,
      location: nil,
      name: nil,
      picture_url: nil,
      statement: nil
    }

    test "list_personal_information/0 returns all personal_information" do
      info = info_fixture()
      assert Enum.member?(Profiles.list_personal_information(), info)
    end

    test "get_info!/1 returns the info with given id" do
      info = info_fixture()
      assert Profiles.get_info!(info.id) == info
    end

    test "create_info/1 with valid data creates a info", %{user_id: user_id, page_id: page_id} do
      valid_attrs = %{
        favorite_editor: "some favorite_editor",
        first_computer: "some first_computer",
        job_title: "some job_title",
        location: "some location",
        name: "some name",
        picture_url: "some picture_url",
        statement: "some statement",
        user_id: user_id,
        page_id: page_id
      }

      assert {:ok, %Info{} = info} = Profiles.create_info(valid_attrs)
      assert info.favorite_editor == "some favorite_editor"
      assert info.first_computer == "some first_computer"
      assert info.job_title == "some job_title"
      assert info.location == "some location"
      assert info.name == "some name"
      assert info.picture_url == "some picture_url"
      assert info.statement == "some statement"
    end

    test "create_info/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_info(@invalid_attrs)
    end

    test "create_and_tag_info/2 with valid data returns the info", %{user_id: user_id, page_id: page_id} do
      result = Profiles.create_and_tag_info(%{name: "Foo", job_title: "Bar", user_id: user_id, page_id: page_id}, [%{name: "Biz"}, %{name: "Baz"}])

      assert %Info{name: "Foo", tags: [%Tag{}, %Tag{}]} = result
    end

    test "update_info/2 with valid data updates the info" do
      info = info_fixture()

      update_attrs = %{
        favorite_editor: "some updated favorite_editor",
        first_computer: "some updated first_computer",
        job_title: "some updated job_title",
        location: "some updated location",
        name: "some updated name",
        picture_url: "some updated picture_url",
        statement: "some updated statement"
      }

      assert {:ok, %Info{} = info} = Profiles.update_info(info, update_attrs)
      assert info.favorite_editor == "some updated favorite_editor"
      assert info.first_computer == "some updated first_computer"
      assert info.job_title == "some updated job_title"
      assert info.location == "some updated location"
      assert info.name == "some updated name"
      assert info.picture_url == "some updated picture_url"
      assert info.statement == "some updated statement"
    end

    test "update_info/2 with invalid data returns error changeset" do
      info = info_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_info(info, @invalid_attrs)
      assert info == Profiles.get_info!(info.id)
    end

    test "delete_info/1 deletes the info" do
      info = info_fixture()
      assert {:ok, %Info{}} = Profiles.delete_info(info)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_info!(info.id) end
    end

    test "change_info/1 returns a info changeset" do
      info = info_fixture()
      assert %Ecto.Changeset{} = Profiles.change_info(info)
    end
  end

  describe "links" do
    alias Story.Profiles.Link

    import Story.ProfilesFixtures

    @invalid_attrs %{active: nil, text: nil, url: nil}

    test "list_links/0 returns all links" do
      link = link_fixture()
      assert Enum.member?(Profiles.list_links(), link)
    end

    test "get_link!/1 returns the link with given id" do
      link = link_fixture()
      assert Profiles.get_link!(link.id) == link
    end

    test "create_link/1 with valid data creates a link", %{page_id: page_id, user_id: user_id} do
      valid_attrs = %{active: true, text: "some text", url: "some url", page_id: page_id, user_id: user_id}

      assert {:ok, %Link{} = link} = Profiles.create_link(valid_attrs)
      assert link.active == true
      assert link.text == "some text"
      assert link.url == "some url"
    end

    test "create_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_link(@invalid_attrs)
    end

    test "update_link/2 with valid data updates the link" do
      link = link_fixture()
      update_attrs = %{active: false, text: "some updated text", url: "some updated url"}

      assert {:ok, %Link{} = link} = Profiles.update_link(link, update_attrs)
      assert link.active == false
      assert link.text == "some updated text"
      assert link.url == "some updated url"
    end

    test "update_link/2 with invalid data returns error changeset" do
      link = link_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_link(link, @invalid_attrs)
      assert link == Profiles.get_link!(link.id)
    end

    test "delete_link/1 deletes the link" do
      link = link_fixture()
      assert {:ok, %Link{}} = Profiles.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_link!(link.id) end
    end

    test "change_link/1 returns a link changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = Profiles.change_link(link)
    end
  end
end
