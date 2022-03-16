defmodule Story.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query, warn: false
  alias Story.Repo

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Story.Tags.Tag{}, ...]

  """
  def list_tags do
    Repo.all(Story.Tags.Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Story.Tags.Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Story.Tags.Tag, id)

  @doc """
  Gets a single tag by name.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> create_tag(%{name: "Foo"})
      iex> get_tag_by_name("Foo")
      {:ok, %Story.Tags.Tag{name: "Foo"}}
  """
  def get_tag_by_name(name), do: Repo.get_by!(Story.Tags.Tag, name: name)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Story.Tags.Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Story.Tags.Tag{}
    |> Story.Tags.Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates or finds a tag.

  ## Examples

      iex> create_or_find_tag(name: "Foo")
      {:ok, %Story.Tags.Tag{}}

      iex> create_or_find_tag(name: "Bar")
      iex> create_or_find_tag(name: "Bar")
      {:ok, %Story.Tags.Tag{name: "Bar"}}
  """
  def create_or_find_tag(attrs \\ %{}) do
    changeset = Story.Tags.Tag.changeset(%Story.Tags.Tag{}, attrs)

    case Repo.insert(changeset) do
      {:error,
       %Ecto.Changeset{errors: [name: {_reason, [constraint: :unique, constraint_name: "tags_name_index"]}]}} ->
        get_tag_by_name(changeset.changes.name)

      {:ok, tag} ->
        tag
    end
  end

  @doc """
  Creates or finds many tags

  ## Examples

      iex> create_or_find_all_tags([%{name, "Foo"}, %{name: "Bar"}])
      [%Story.Tags.Tag{name: "Foo"}, %Tag{name: "Bar"}]
  """
  def create_or_find_all_tags(tags_attrs) do
    Enum.map(tags_attrs, &create_or_find_tag/1)
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Story.Tags.Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Story.Tags.Tag{} = tag, attrs) do
    tag
    |> Story.Tags.Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Story.Tags.Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Story.Tags.Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Story.Tags.Tag{}}

  """
  def change_tag(%Story.Tags.Tag{} = tag, attrs \\ %{}) do
    Story.Tags.Tag.changeset(tag, attrs)
  end

  alias Story.Tags.InfoTag

  @doc """
  Returns the list of personal_information_tags.

  ## Examples

      iex> list_personal_information_tags()
      [%InfoTag{}, ...]

  """
  def list_personal_information_tags do
    Repo.all(InfoTag)
  end

  @doc """
  Gets a single info_tag.

  Raises `Ecto.NoResultsError` if the Info tag does not exist.

  ## Examples

      iex> get_info_tag!(123)
      %InfoTag{}

      iex> get_info_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_info_tag!(id), do: Repo.get!(InfoTag, id)

  @doc """
  Creates a info_tag.

  ## Examples

      iex> create_info_tag(%{field: value})
      {:ok, %InfoTag{}}

      iex> create_info_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_info_tag(attrs \\ %{}) do
    %InfoTag{}
    |> InfoTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a info_tag.

  ## Examples

      iex> update_info_tag(info_tag, %{field: new_value})
      {:ok, %InfoTag{}}

      iex> update_info_tag(info_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_info_tag(%InfoTag{} = info_tag, attrs) do
    info_tag
    |> InfoTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a info_tag.

  ## Examples

      iex> delete_info_tag(info_tag)
      {:ok, %InfoTag{}}

      iex> delete_info_tag(info_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_info_tag(%InfoTag{} = info_tag) do
    Repo.delete(info_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking info_tag changes.

  ## Examples

      iex> change_info_tag(info_tag)
      %Ecto.Changeset{data: %InfoTag{}}

  """
  def change_info_tag(%InfoTag{} = info_tag, attrs \\ %{}) do
    InfoTag.changeset(info_tag, attrs)
  end

  alias Story.Tags.StatTag

  @doc """
  Returns the list of stat_tags.

  ## Examples

      iex> list_stat_tags()
      [%StatTag{}, ...]

  """
  def list_stat_tags do
    Repo.all(StatTag)
  end

  @doc """
  Gets a single stat_tag.

  Raises `Ecto.NoResultsError` if the Stat tag does not exist.

  ## Examples

      iex> get_stat_tag!(123)
      %StatTag{}

      iex> get_stat_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stat_tag!(id), do: Repo.get!(StatTag, id)

  @doc """
  Creates a stat_tag.

  ## Examples

      iex> create_stat_tag(%{field: value})
      {:ok, %StatTag{}}

      iex> create_stat_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stat_tag(attrs \\ %{}) do
    %StatTag{}
    |> StatTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a stat_tag.

  ## Examples

      iex> update_stat_tag(stat_tag, %{field: new_value})
      {:ok, %StatTag{}}

      iex> update_stat_tag(stat_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stat_tag(%StatTag{} = stat_tag, attrs) do
    stat_tag
    |> StatTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a stat_tag.

  ## Examples

      iex> delete_stat_tag(stat_tag)
      {:ok, %StatTag{}}

      iex> delete_stat_tag(stat_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stat_tag(%StatTag{} = stat_tag) do
    Repo.delete(stat_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stat_tag changes.

  ## Examples

      iex> change_stat_tag(stat_tag)
      %Ecto.Changeset{data: %StatTag{}}

  """
  def change_stat_tag(%StatTag{} = stat_tag, attrs \\ %{}) do
    StatTag.changeset(stat_tag, attrs)
  end

  alias Story.Tags.TimelineItemTag

  @doc """
  Returns the list of timeline_item_tags.

  ## Examples

      iex> list_timeline_item_tags()
      [%TimelineItemTag{}, ...]

  """
  def list_timeline_item_tags do
    Repo.all(TimelineItemTag)
  end

  @doc """
  Gets a single timeline_item_tag.

  Raises `Ecto.NoResultsError` if the Timeline item tag does not exist.

  ## Examples

      iex> get_timeline_item_tag!(123)
      %TimelineItemTag{}

      iex> get_timeline_item_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timeline_item_tag!(id), do: Repo.get!(TimelineItemTag, id)

  @doc """
  Creates a timeline_item_tag.

  ## Examples

      iex> create_timeline_item_tag(%{field: value})
      {:ok, %TimelineItemTag{}}

      iex> create_timeline_item_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timeline_item_tag(attrs \\ %{}) do
    %TimelineItemTag{}
    |> TimelineItemTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timeline_item_tag.

  ## Examples

      iex> update_timeline_item_tag(timeline_item_tag, %{field: new_value})
      {:ok, %TimelineItemTag{}}

      iex> update_timeline_item_tag(timeline_item_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timeline_item_tag(%TimelineItemTag{} = timeline_item_tag, attrs) do
    timeline_item_tag
    |> TimelineItemTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a timeline_item_tag.

  ## Examples

      iex> delete_timeline_item_tag(timeline_item_tag)
      {:ok, %TimelineItemTag{}}

      iex> delete_timeline_item_tag(timeline_item_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timeline_item_tag(%TimelineItemTag{} = timeline_item_tag) do
    Repo.delete(timeline_item_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timeline_item_tag changes.

  ## Examples

      iex> change_timeline_item_tag(timeline_item_tag)
      %Ecto.Changeset{data: %TimelineItemTag{}}

  """
  def change_timeline_item_tag(%TimelineItemTag{} = timeline_item_tag, attrs \\ %{}) do
    TimelineItemTag.changeset(timeline_item_tag, attrs)
  end
end
