defmodule StoryWeb.ImportLive do
  use StoryWeb, :live_view
  alias Story.Accounts
  alias Story.SOStoryScraper

  def mount(params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    so_url = params["so_url"]

    if so_url do
      send(self(), {:import, so_url})
    end

    {:ok,
     socket
     |> assign(:so_url, params["so_url"])
     |> assign(:page, nil)
     |> assign(:current_user, current_user)}
  end

  def render(assigns) do
    ~H"""
    <%= if @so_url && !@page do %>
      <div class="lg:w-1/2 mx-auto alert shadow-sm alert-info my-12">
        <div class="items-center">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current flex-shrink-0 w-6 h-6 mr-2"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
          <span>Importing your story. This page will update when the process is complete.</span>
        </div>
      </div>
    <% end %>

    <%= if !@so_url do %>
      <div class="lg:w-1/2 mx-auto my-12">
        <h1 class="text-5xl font-bold mb-8">StackOverflow Import</h1>
        <p class="mb-4 text-secondary">Import your StackOverflow story.</p>

        <form phx-submit="fetch-story">
          <div class="p-10 card bg-base-100 shadow-sm border border-base-300">
            <div class="form-control mb-8">
              <label for="so_url" class="label font-bold">
                <span class="label-text">StackOverflow Story URL:</span>
              </label>
              <input type="text" class="input input-bordered" name="so_url" placeholder="https://stackoverflow.com/story/my-vanity-url" />
              <p class="text-secondary text-xs pt-2">Example: <br /> https://stackoverflow.com/story/my-vanity-url <strong>OR</strong> https://stackoverflow.com/users/story/123456</p>
             </div>
             <div>
               <button class="btn btn-primary">Import</button>
             </div>
          </div>
        </form>
      </div>
    <% end %>


    <%= if @page do %>
      <%= StoryWeb.PageView.render("show.html", page: @page) %>
    <% end %>
    """
  end

  def handle_event("fetch-story", %{"so_url" => so_url}, socket) do
    send(self(), {:import, so_url})

    {:noreply,
     socket
     |> assign(:so_url, so_url)}
  end

  def handle_info({:import, so_url}, socket) do
    current_user = socket.assigns.current_user

    page =
      Story.Pages.create_or_find_page(%{
        description: "Imported from StackOverflow",
        slug: current_user.slug || SecureRandom.uuid,
        title: "My DevStory",
        user_id: current_user.id
      })

    result = SOStoryScraper.fetch_and_save(so_url, %{page_id: page.id, user_id: current_user.id})

    {:noreply,
     socket
     |> put_flash(:info, "Your content has been imported!")
     |> push_redirect(to: "/users/story/edit", replace: true)}
  end
end
