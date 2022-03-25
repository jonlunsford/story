defmodule Story.Timelines do
  @moduledoc """
  The Timelines context.
  """

  import Ecto.Query, warn: false
  alias Story.Repo

  alias Story.Timelines.Item

  @doc """
  Returns the list of timeline_items.

  ## Examples

      iex> list_timeline_items()
      [%Item{}, ...]

  """
  def list_timeline_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  def get_items_by_page_id(page_id) do
    Item
    |> where(page_id: ^page_id)
    |> Repo.all()
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates and tags items
  """
  def create_and_tag_item(attrs, tags \\ []) do
    item =
      case create_item(attrs) do
        {:ok, item} -> item
        {:error, changeset} -> changeset
      end

    tags = Story.Tags.create_or_find_all_tags(tags)

    Enum.map(tags, fn tag ->
      Story.Tags.create_timeline_item_tag(%{timeline_item_id: item.id, tag_id: tag.id})
    end)

    Map.put(item, :tags, tags)
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    item = Repo.get_by!(Item, user_id: item.user_id, id: item.id)

    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
