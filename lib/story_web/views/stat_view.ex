defmodule StoryWeb.StatView do
  use StoryWeb, :view

  def render_stat("assessment", assigns) do
    render("assessment.html", assigns)
  end

  def render_stat(_, assigns) do
    render("default.html", assigns)
  end
end
