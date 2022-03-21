defmodule StoryWeb.API.ExportsView do
  use StoryWeb, :view

  alias Story.JSONResumeSerializer

  def render("page.json", %{page_html: page_html}) do
    page_json = JSONResumeSerializer.call(page_html)
    case Jason.encode(page_json) do
      {:ok, json} -> json
      {:error, _} -> "error"
    end
  end
end
