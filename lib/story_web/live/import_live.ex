defmodule StoryWeb.ImportLive do
  use StoryWeb, :live_view
  alias Story.Accounts
  alias Story.SOStoryScraper
  alias Phoenix.LiveView.JS

  def mount(%{"so_url" => so_url}, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    {:ok,
     socket
     |> assign(:so_url, so_url)
     |> assign(:page, nil)
     |> assign(:current_user, current_user)}
  end

  def render(assigns) do
    ~H"""
    <%= if @page do %>
      <%= StoryWeb.PageView.render("show.html", page: @page) %>
    <% end %>
    """
  end
end
