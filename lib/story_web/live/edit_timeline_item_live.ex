defmodule StoryWeb.EditTimelineItemLive do
  use StoryWeb, :live_component

  import StoryWeb.LayoutView, only: [underscore_string: 1, dasherize_string: 1]

  alias Story.Timelines
  alias Phoenix.LiveView.JS
  alias Story.S3UploadHelpers

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:current_user_id, assigns.current_user_id)
     |> assign(:edit_changeset, Timelines.change_item(assigns.item))
     |> assign(:item, assigns.item)
     |> allow_upload(:img,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 4_000_000,
       external: &presign_upload/2
     )}
  end

  def render(assigns) do
    ~H"""
    <div id={"edit-timeline-item-#{@item.id}"} class={"timeline-item #{dasherize_string(@item.type)}"}>
      <%= StoryWeb.TimelineView.render_form(
          "#{underscore_string(@item.type)}",
          changeset: @edit_changeset,
          item: @item,
          uploads: @uploads,
          on_cancel: &hide_form/1,
          myself: @myself) %>

      <%= StoryWeb.TimelineView.render_item(
          "#{underscore_string(@item.type)}",
          item: @item,
          myself: @myself,
          header_content: &gear_dropdown/1) %>
    </div>
    """
  end

  def gear_dropdown(assigns) do
    ~H"""
    <div class="dropdown dropdown-end text-base">
      <label tabindex="0" class="cursor-pointer">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
      </label>

      <ul tabindex="0" class="p-2 shadow menu dropdown-content bg-base-100 border border-base-200 rounded-md w-32">
        <li><a phx-click={show_form(@item)}>Edit</a></li>
        <li><a data-confirm="Are you sure? This cannot be undone." phx-click="delete" phx-value-id={@item.id} phx-target={@myself}>Delete</a></li>
      </ul>
    </div>
    """
  end

  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset =
      socket.assigns.item
      |> Timelines.change_item(item_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :edit_changeset, changeset)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    picture_url = S3UploadHelpers.get_image_url(socket, :img)

    item_params =
      if picture_url do
        Map.put(item_params, "img", picture_url)
      else
        item_params
      end

    case Timelines.update_item(socket.assigns.item, item_params) do
      {:ok, item} ->
        {:noreply,
          socket
          |> assign(:item, item)
          |> push_event("remove-class", %{selector: "#item-#{item.id}-content", class: "hidden"})
          |> push_event("add-class", %{selector: "#item-#{item.id}-form", class: "hidden"})
          |> assign(:edit_changeset, Timelines.change_item(item))}
      {:error, changeset} ->
        {:noreply, assign(socket, :edit_changeset, changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    item = %Timelines.Item{user_id: socket.assigns.current_user_id, id: id}

    Timelines.delete_item(item)

    {:noreply,
     socket
     |> push_event("add-class", %{selector: "#edit-timeline-item-#{id}", class: "hidden"})}
  end

  def show_form(item, js \\ %JS{}) do
    js
    |> JS.remove_class("hidden", to: "#item-#{item.id}-form")
    |> JS.add_class("hidden", to: "#item-#{item.id}-content")
  end

  def hide_form(item, js \\ %JS{}) do
    js
    |> JS.remove_class("hidden", to: "#item-#{item.id}-content")
    |> JS.add_class("hidden", to: "#item-#{item.id}-form")
  end

  defp presign_upload(entry, socket) do
    S3UploadHelpers.presign_upload(entry, socket, :img)
  end
end
