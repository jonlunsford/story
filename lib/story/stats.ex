defmodule Story.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias Story.Repo

  alias Story.Stats.Stat

  @doc """
  Returns the list of stats.

  ## Examples

      iex> list_stats()
      [%Stat{}, ...]

  """
  def list_stats do
    Repo.all(Stat)
  end

  @doc """
  Gets a single stat.

  Raises `Ecto.NoResultsError` if the Stat does not exist.

  ## Examples

      iex> get_stat!(123)
      %Stat{}

      iex> get_stat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stat!(id), do: Repo.get!(Stat, id)

  @doc """
  Creates a stat.

  ## Examples

      iex> create_stat(%{field: value})
      {:ok, %Stat{}}

      iex> create_stat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stat(attrs \\ %{}) do
    %Stat{}
    |> Stat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates and tags stats
  """
  def create_and_tag_stat(attrs, tags \\ []) do
    stat =
      case create_stat(attrs) do
        {:ok, stat} -> stat
        {:error, changeset} -> changeset
      end

    tags = Story.Tags.create_or_find_all_tags(tags)

    Enum.map(tags, fn tag ->
      Story.Tags.create_stat_tag(%{stat_id: stat.id, tag_id: tag.id})
    end)

    Map.put(stat, :tags, tags)
  end

  @doc """
  Updates a stat.

  ## Examples

      iex> update_stat(stat, %{field: new_value})
      {:ok, %Stat{}}

      iex> update_stat(stat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stat(%Stat{} = stat, attrs) do
    stat
    |> Stat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a stat.

  ## Examples

      iex> delete_stat(stat)
      {:ok, %Stat{}}

      iex> delete_stat(stat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stat(%Stat{} = stat) do
    Repo.delete(stat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stat changes.

  ## Examples

      iex> change_stat(stat)
      %Ecto.Changeset{data: %Stat{}}

  """
  def change_stat(%Stat{} = stat, attrs \\ %{}) do
    Stat.changeset(stat, attrs)
  end
end
