defmodule Story.Pages do
  @moduledoc """
  The Pages context.
  """

  import Ecto.Query, warn: false
  alias Story.Repo

  alias Story.Pages.Page

  @doc """
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def list_pages do
    Repo.all(Page)
  end

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page!(id), do: Repo.get!(Page, id)

  @doc """
  Gets a single page by slug.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> create_page(%{slug: "Foo"})
      iex> get_page_by_slug("Foo")
      {:ok, %Page{slug: "Foo"}}
  """
  def get_page_by_slug_for_user(slug, user_id),
    do: Repo.get_by!(Page, slug: slug, user_id: user_id)

  def get_page_by_slug(slug) do
    Repo.get_by(Page, slug: slug)
    |> Repo.preload(
      personal_information: [:tags],
      stats: [:tags],
      timeline_items: [:tags],
      readings: []
    )
  end

  def get_published_page_by_slug(slug) do
    Repo.get_by(Page, slug: slug, published: true)
    |> Repo.preload(
      personal_information: [:tags],
      stats: [:tags],
      timeline_items: [:tags],
      readings: []
    )
  end

  def get_user_latest_page(user) do
    Page
    |> where(user_id: ^user.id)
    |> last()
    |> Repo.one()
    |> Repo.preload(
      personal_information: [:tags],
      stats: [:tags],
      timeline_items: [:tags],
      readings: []
    )
  end

  def get_user_latest_page_without_preloads(user) do
    Page
    |> where(user_id: ^user.id)
    |> last()
    |> Repo.one()
  end

  @doc """
  Creates a page.

  ## Examples

      iex> create_page(%{field: value})
      {:ok, %Page{}}

      iex> create_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates or finds a page.

  ## Examples

      iex> create_or_find_page(slug: "Foo")
      {:ok, %Tag{}}

      iex> create_or_find_page(name: "Bar")
      iex> create_or_find_page(name: "Bar")
      {:ok, %Page{name: "Bar"}}
  """
  def create_or_find_page(attrs \\ %{}) do
    changeset = Page.changeset(%Page{}, attrs)

    case Repo.insert(changeset) do
      {:error,
       %Ecto.Changeset{
         errors: [slug: {_reason, [constraint: :unique, constraint_name: "pages_slug_index"]}]
       }} ->
        get_page_by_slug_for_user(changeset.changes.slug, changeset.changes.user_id)

      {:ok, page} ->
        page
    end
  end

  @doc """
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a page.

  ## Examples

      iex> delete_page(page)
      {:ok, %Page{}}

      iex> delete_page(page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.

  ## Examples

      iex> change_page(page)
      %Ecto.Changeset{data: %Page{}}

  """
  def change_page(%Page{} = page, attrs \\ %{}) do
    Page.changeset(page, attrs)
  end

  alias Story.Pages.Reading

  @doc """
  Returns the list of readings.

  ## Examples

      iex> list_readings()
      [%Reading{}, ...]

  """
  def list_readings do
    Repo.all(Reading)
  end

  @doc """
  Gets a single reading.

  Raises `Ecto.NoResultsError` if the Reading does not exist.

  ## Examples

      iex> get_reading!(123)
      %Reading{}

      iex> get_reading!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reading!(id), do: Repo.get!(Reading, id)

  @doc """
  Creates a reading.

  ## Examples

      iex> create_reading(%{field: value})
      {:ok, %Reading{}}

      iex> create_reading(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reading(attrs \\ %{}) do
    %Reading{}
    |> Reading.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reading.

  ## Examples

      iex> update_reading(reading, %{field: new_value})
      {:ok, %Reading{}}

      iex> update_reading(reading, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reading(%Reading{} = reading, attrs) do
    reading
    |> Reading.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reading.

  ## Examples

      iex> delete_reading(reading)
      {:ok, %Reading{}}

      iex> delete_reading(reading)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reading(%Reading{} = reading) do
    reading = Repo.get_by!(Reading, user_id: reading.user_id, id: reading.id)
    Repo.delete(reading)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reading changes.

  ## Examples

      iex> change_reading(reading)
      %Ecto.Changeset{data: %Reading{}}

  """
  def change_reading(%Reading{} = reading, attrs \\ %{}) do
    Reading.changeset(reading, attrs)
  end
end
