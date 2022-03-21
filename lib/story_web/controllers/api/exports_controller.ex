defmodule StoryWeb.API.ExportsController do
  @moduledoc """
  Public API for exports
  """
  use StoryWeb, :controller

  alias Story.SOStoryScraper
  alias Story.JSONResumeSerializer

  def json(conn, %{"so_url" => so_url}) do
    case SOStoryScraper.fetch_and_parse(so_url) do
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> put_root_layout(false)
        |> render("page.json")

      {html, result} ->
        page_html = SOStoryScraper.parse_to_structs({html, result})

        conn
        |> put_root_layout(false)
        |> put_resp_content_type("application/json")
        |> put_resp_header("content-disposition", "attachment; filename=so_story_as_json_resume.json")
        |> render("page.json", page_html: page_html)
    end
  end
end
