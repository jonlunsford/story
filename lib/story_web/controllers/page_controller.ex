defmodule StoryWeb.PageController do
  use StoryWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
