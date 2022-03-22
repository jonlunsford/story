defmodule StoryWeb.API.ExportsController do
  @moduledoc """
  Public API for exports
  """
  use StoryWeb, :controller

  alias Story.SOStoryScraper

  def json(conn, %{"page_id" => page_id}) do
    page = Story.Pages.get_page_with_associations!(page_id)

    conn
    |> put_root_layout(false)
    |> put_resp_content_type("application/json")
    |> put_resp_header("content-disposition", "attachment; filename=so_story_as_json_resume.json")
    |> render("page.json", page: page)
  end

  def json(conn, %{"so_url" => so_url}) do
    case SOStoryScraper.fetch_and_parse(so_url) do
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> put_root_layout(false)
        |> render("page.json")

      {html, result} ->
        page = SOStoryScraper.parse_to_structs({html, result})

        conn
        |> put_root_layout(false)
        |> put_resp_content_type("application/json")
        |> put_resp_header("content-disposition", "attachment; filename=so_story_as_json_resume.json")
        |> render("page.json", page: page)
    end
  end
end
