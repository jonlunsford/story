defmodule StoryWeb.PreviewLive do
  use StoryWeb, :live_view
  alias Story.Accounts
  alias Story.Accounts.User
  alias Phoenix.LiveView.JS
  alias Story.SOStoryScraper

  def mount(_params, _session, socket) do
    # {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    # page = SOStoryScraper.parse_to_structs({html, %{}})

    {:ok,
     socket
     |> assign(:changeset, Accounts.change_user_registration(%User{}))
     |> assign(:vanity_slug, nil)
     |> assign(:page, nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="lg:w-1/2 mx-auto mb-12 sticky -top-36 z-10">
      <h1 class="text-5xl font-bold mb-8">Preview</h1>
      <p class="mb-4 text-secondary">Preview your StackOverflow story, create an account to save, edit, share and claim your DevStory vanity url.</p>

      <%= if !@page do %>
        <form phx-submit="fetch-story">
          <div class="p-10 card bg-base-100 shadow-lg border border-base-300">
            <div class="form-control mb-8">
              <label for="so_url" class="label font-bold">
                <span class="label-text">StackOverflow Story URL:</span>
              </label>
              <input type="text" class="input input-bordered" name="so_url" placeholder="https://stackoverflow.com/story/my-vanity-url" />
              <p class="text-secondary text-xs pt-2">Example: <br /> https://stackoverflow.com/story/my-vanity-url <strong>OR</strong> https://stackoverflow.com/users/story/123456</p>
             </div>
             <div>
               <button class="btn btn-primary">Preview</button>
             </div>
          </div>
        </form>
      <% end %>

      <%= if @page do %>
        <button phx-click={JS.add_class("modal-open", to: "#regisration-modal")} class="btn btn-accent bg-opacity-95 btn-block modal-button rounded-t-none">Create Account to Save, Edit & Share</button>
        <%= StoryWeb.UserRegistrationView.render("modal.html", changeset: @changeset, on_submit: "register-user") %>
      <% end %>
    </div>

    <%= if @page do %>
      <%= StoryWeb.PageView.render("show.html", page: @page) %>
    <% end %>
    """
  end

  def handle_event("fetch-story", %{"so_url" => so_url}, socket) do
    {html, story} = SOStoryScraper.fetch_and_parse(so_url)
    page = SOStoryScraper.parse_to_structs({html, story})

    slug =
      case String.contains?(so_url, "stackoverflow.com/story/") do
        true ->
          "https://stackoverflow.com/story/" <> vanity_slug = so_url
          vanity_slug

        false ->
          nil
      end

    {:noreply,
     socket
     |> assign(:so_url, so_url)
     |> assign(:vanity_slug, slug)
     |> assign(:page, page)}
  end

  def handle_event("register-user", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(socket, :edit, &1)
          )

        {:noreply,
         socket
         |> put_flash(:info, "Account created! Hang tight while your content is now imported.")
         |> redirect(to: Routes.user_session_path(StoryWeb.Endpoint, :create_from_preview, %{user: user_params, so_url: socket.assigns.so_url}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # defp load_file(relative_path) do
  # (File.cwd!() <> relative_path)
  # |> Path.expand(relative_path)
  # |> Path.absname()
  # |> File.read()
  # end
end
