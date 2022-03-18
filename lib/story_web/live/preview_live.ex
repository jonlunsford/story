defmodule StoryWeb.PreviewLive do
  use StoryWeb, :live_view
  alias Story.Accounts
  alias Story.Accounts.User
  alias Phoenix.LiveView.JS
  alias Story.SOStoryScraper

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:changeset, nil)
     |> assign(:page, nil)}
  end

  def render(assigns) do
    ~H"""
    <%= if !@page do %>
      <div class="lg:w-1/2 mx-auto my-12 px-8 lg:px-0">
        <h1 class="text-5xl text-center md:text-left font-extrabold mb-8">StackOverflow Import</h1>
        <p class="mb-4 text-neutral text-center md:text-left">Preview your StackOverflow story, create an account to save, share and claim your DevStory vanity url.</p>

        <form phx-submit="fetch-story" phx-validate="validate">
          <div class="p-10 card bg-base-100 shadow-md border border-base-300">
            <div class="form-control mb-8">
              <label for="so_url" class="label font-bold">
                <span class="label-text">StackOverflow Story URL:</span>
              </label>
              <input type="text" class="input input-bordered" name="so_url" placeholder="https://stackoverflow.com/story/my-vanity-url" />
              <p class="text-neutral text-xs pt-2">Example: <br /> https://stackoverflow.com/story/my-vanity-url <strong>OR</strong> https://stackoverflow.com/users/story/123456</p>
             </div>
             <div>
               <button class="btn btn-primary">Preview</button>
             </div>
          </div>
        </form>
      </div>
    <% end %>

    <%= if @page do %>
      <button phx-click={JS.add_class("modal-open", to: "#regisration-modal")} class="btn btn-accent bg-opacity-95 mt-12 center sticky top-0 z-10 btn-block modal-button rounded-none md:rounded-md">Create an Account to Save, Edit & Share</button>
      <%= StoryWeb.UserRegistrationView.render("modal.html", changeset: @changeset, on_submit: "register-user") %>
    <% end %>

    <%= if @page do %>
      <div class="mt-8">
        <%= StoryWeb.PageView.render("show.html", page: @page, myself: nil) %>
      </div>
    <% end %>
    """
  end

  def handle_event("fetch-story", %{"so_url" => so_url}, socket) do
    case SOStoryScraper.fetch_and_parse(so_url) do
      {:ok, page} ->
        slug =
          case String.contains?(so_url, "stackoverflow.com/story/") do
            true ->
              "https://stackoverflow.com/story/" <> vanity_slug = so_url
              vanity_slug

            false ->
              nil
          end

        changeset = Accounts.change_user_registration(%User{}, %{slug: slug})

        {:noreply,
         socket
         |> clear_flash()
         |> assign(:so_url, so_url)
         |> assign(:changeset, changeset)
         |> assign(:page, page)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, reason)}
    end
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
         |> redirect(
           to:
             Routes.user_session_path(StoryWeb.Endpoint, :create_from_preview, %{
               user: user_params,
               so_url: socket.assigns.so_url
             })
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
