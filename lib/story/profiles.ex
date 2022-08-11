defmodule Story.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias Story.Repo

  alias Story.Profiles.Info

  @doc """
  Returns the list of personal_information.

  ## Examples

      iex> list_personal_information()
      [%Info{}, ...]

  """
  def list_personal_information do
    Repo.all(Info)
  end

  @doc """
  Gets a single info.

  Raises `Ecto.NoResultsError` if the Info does not exist.

  ## Examples

      iex> get_info!(123)
      %Info{}

      iex> get_info!(456)
      ** (Ecto.NoResultsError)

  """
  def get_info!(id), do: Repo.get!(Info, id)

  def get_infos_by_page_id(page_id) do
    Info
    |> where(page_id: ^page_id)
    |> Repo.all()
  end

  def get_current_info_by_user_id(user_id) do
    case Info
         |> where(user_id: ^user_id)
         |> Repo.one() do
      nil ->
        %Info{name: "Anonymous-#{user_id}"}

      info ->
        info
        |> Map.put_new(:name, "Anonymous-#{user_id}")
    end
  end

  @doc """
  Creates a info.

  ## Examples

      iex> create_info(%{field: value})
      {:ok, %Info{}}

      iex> create_info(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_info(attrs \\ %{}) do
    %Info{}
    |> Info.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates and tags info at the same time

  ## Examples

      iex> create_and_tag_info(%{name: "Foo", job_title: "Bar"}, [%{name: "Biz"}, %{name: "Baz"}])
      %Info{name: "Foo", tags: [%Tag{}, %Tag{}]}
  """
  def create_and_tag_info(attrs, tags \\ []) do
    info =
      case create_info(attrs) do
        {:ok, info} -> info
        {:error, changeset} -> changeset
      end

    tags = Story.Tags.create_or_find_all_tags(tags)

    Enum.map(tags, fn tag ->
      Story.Tags.create_info_tag(%{personal_information_id: info.id, tag_id: tag.id})
    end)

    Map.put(info, :tags, tags)
  end

  @doc """
  Updates a info.

  ## Examples

      iex> update_info(info, %{field: new_value})
      {:ok, %Info{}}

      iex> update_info(info, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_info(%Info{} = info, attrs) do
    info
    |> Info.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a info.

  ## Examples

      iex> delete_info(info)
      {:ok, %Info{}}

      iex> delete_info(info)
      {:error, %Ecto.Changeset{}}

  """
  def delete_info(%Info{} = info) do
    Repo.delete(info)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking info changes.

  ## Examples

      iex> info = create_info%{name: "Foo"}
      iex> change_info(info)
      %Ecto.Changeset{data: %Info{}}

  """
  def change_info(%Info{} = info, attrs \\ %{}) do
    Info.changeset(info, attrs)
  end

  def info_listing_technologies?(info) do
    [info.technologies_desired, info.technologies_expert, info.technologies_undesired]
    |> Enum.any?
  end

  alias Story.Profiles.Link

  @doc """
  Returns the list of links.

  ## Examples

      iex> list_links()
      [%Link{}, ...]

  """
  def list_links do
    Repo.all(Link)
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!(123)
      %Link{}

      iex> get_link!(456)
      ** (Ecto.NoResultsError)

  """
  def get_link!(id), do: Repo.get!(Link, id)

  @doc """
  Creates a link.

  ## Examples

      iex> create_link(%{field: value})
      {:ok, %Link{}}

      iex> create_link(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link(attrs \\ %{}) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update_link(link, %{field: new_value})
      {:ok, %Link{}}

      iex> update_link(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a link.

  ## Examples

      iex> delete_link(link)
      {:ok, %Link{}}

      iex> delete_link(link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking link changes.

  ## Examples

      iex> change_link(link)
      %Ecto.Changeset{data: %Link{}}

  """
  def change_link(%Link{} = link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end
end
