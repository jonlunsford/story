defmodule StoryWeb.EditReadingLive do
  use StoryWeb, :live_component

  alias Phoenix.LiveView.JS
  alias Story.Pages

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(:current_user_id, assigns.current_user_id)
      |> assign(:changeset, Pages.change_reading(assigns.reading))
      |> assign(:reading, assigns.reading)}
  end

  def render(assigns) do
    ~H"""
    <div id={"edit-reading-#{@reading.id}"} class="border shadow-sm bg-base-100 rounded-md p-6 flex">
      <%= if @myself do %>
        <%= StoryWeb.PageView.render(
            "reading_form.html",
            changeset: @changeset,
            reading: @reading,
            myself: @myself) %>
      <% end %>

      <div class="text-secondary mr-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
        </svg>
      </div>

      <div>
        <a href={@reading.url} alt={@reading.title} class="link link-primary">
          <%= @reading.title %>
        </a>
        <p class="text-xs text-secondary mt-1"><%= @reading.author %></p>

        <dif class="line-clamp-4 text-xs mt-2">
          <%= raw @reading.description %>
        </dif>
      </div>

      <%= if @myself do %>
        <div class="dropdown dropdown-end text-secondary">
          <label tabindex="0" class="cursor-pointer">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </label>

          <ul tabindex="0" class="p-2 shadow menu dropdown-content bg-base-100 border border-base-200 rounded-md w-32">
            <li><a phx-click={JS.remove_class("hidden", to: "#reading-#{@reading.id}-form") |> JS.add_class("hidden", to: "#reading-#{@reading.id}-content")} phx-value-id={@reading.id} phx-target={@myself}>Edit</a></li>
            <li><a phx-click="delete" phx-value-id={@reading.id} phx-target={@myself}>Delete</a></li>
          </ul>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("validate", %{"reading" => reading_params}, socket) do
    changeset =
      socket.assigns.reading
      |> Pages.change_reading(reading_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"reading" => reading_params}, socket) do
    case Pages.update_reading(socket.assigns.reading, reading_params) do
      {:ok, reading} ->
        {:noreply,
          socket
          |> assign(:reading, reading)
          |> push_event("add-class", %{selector: "#reading-#{reading.id}-form", class: "hidden"})
          |> assign(:changeset, Pages.change_reading(reading))}
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    id = String.to_integer(id)
    reading = %Pages.Reading{user_id: socket.assigns.current_user_id, id: id}

    Pages.delete_reading(reading)

    {:noreply,
     socket
     |> push_event("add-class", %{selector: "#edit-reading-#{id}", class: "hidden"})}
  end
end
