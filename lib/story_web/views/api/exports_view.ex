defmodule StoryWeb.API.ExportsView do
  use StoryWeb, :view

  alias Story.JSONResumeSerializer

  def render("page.json", %{page: page}) do
    JSONResumeSerializer.call(page)
  end
end
