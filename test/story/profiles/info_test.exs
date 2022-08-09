# test/story/profiles/info_test.exs
defmodule Story.Profiles.InfoTest do
  use Story.DataCase

  alias Story.Profiles.Info
  alias Story.Tags.Tag

  test "copy_tags/1 merges existing tags with technologies_desired" do
    tags = [%Tag{name: "foo"}, %Tag{name: "bar"}]
    info = %Info{tags: tags, name: "name", user_id: 0}
    result = Info.copy_tags(info)

    assert result.technologies_desired == "foo, bar"
  end

  test "copy_tags/1 does not merge tags if technologies_desired is populated" do
    tags = [%Tag{name: "foo"}, %Tag{name: "bar"}]
    info = %Info{tags: tags, technologies_desired: "biz, baz", name: "name", user_id: 0}
    result = Info.copy_tags(info)

    assert result.technologies_desired == "biz, baz"
  end
end
