defmodule StoryWeb.PageController do
  use StoryWeb, :controller

  alias Story.Pages

  def index(conn, _params) do
    case conn.assigns.current_user do
      nil -> render(conn, "index.html")
      user ->
        page = Pages.get_user_latest_page(user)

        if page do
          conn
          |> redirect(to: Routes.live_path(conn, StoryWeb.EditLive))
        else
          render(conn, "dashboard.html")
        end
    end
  end

  def show(conn, %{"slug" => slug}) do
    case Pages.get_published_page_by_slug(slug) do
      nil -> render(conn, "404.html")
      page ->
        conn
        |> put_root_layout("public.html")
        |> render("show.html", page: page, myself: nil)
    end
  end

  def cv(conn, %{"slug" => slug}) do
    case Pages.get_published_page_by_slug(slug) do
      nil -> render(conn, "404.html")
      page ->
        conn
        |> put_root_layout("public.html")
        |> render("cv.html", page: page, myself: nil)
    end
  end
end
