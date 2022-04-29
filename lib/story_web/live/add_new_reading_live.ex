defmodule StoryWeb.AddNewReadingLive do
  use StoryWeb, :live_component

  import StoryWeb.LayoutView, only: [markdown_as_html: 1]

  alias Story.Pages
  alias Phoenix.LiveView.JS

  def update(assigns, socket) do
    reading = %Pages.Reading{id: "new"}
    {:ok,
      socket
      |> assign(:page_id, assigns.page_id)
      |> assign(:current_user_id, assigns.current_user_id)
      |> assign(:reading, reading)
      |> assign(:markdown_html, nil)
      |> assign(:changeset, Pages.change_reading(reading))}
  end

  def render(assigns) do
    ~H"""
    <div class="text-center">
      <%= StoryWeb.PageView.render(
          "reading_form.html",
          changeset: @changeset,
          reading: @reading,
          markdown_html: @markdown_html,
          myself: @myself) %>

      <button phx-click={JS.remove_class("hidden", to: "#reading-new-form")} class="rounded-sm btn btn-neutral btn-outline btn-sm mx-auto w-1/3">Add Reading</button>
      <p class="italic font-xs font-light mt-4 md:w-1/2 mx-auto">What are some things you've read that showcase what you're learning?</p>
    </div>
    """
  end

  def handle_event("validate", %{"reading" => reading_params}, socket) do
    changeset =
      socket.assigns.reading
      |> Pages.change_reading(reading_params)
      |> Map.put(:action, :insert)

    markdown_html = markdown_as_html(Map.get(reading_params, "description"))

    {:noreply,
      socket
      |> assign(:markdown_html, markdown_html)
      |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"reading" => reading_params}, socket) do
    reading_params =
      reading_params
      |> Map.put("user_id", socket.assigns.current_user_id)
      |> Map.put("page_id", socket.assigns.page_id)

    case Pages.create_reading(reading_params) do
      {:ok, reading} ->

        send(self(), {:added_reading, reading})

        {:noreply,
          socket
          |> assign(:reading, reading)
          |> push_event("add-class", %{selector: "#reading-new-form", class: "hidden"})
          |> assign(:changeset, Pages.change_reading(reading))}
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
