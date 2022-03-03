defmodule StoryWeb.EditTimelineItemLive do
  use StoryWeb, :live_component

  import StoryWeb.LayoutView, only: [underscore_string: 1]

  alias Story.Timelines

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:current_user_id, assigns.current_user.id)
     |> assign(:changeset, Timelines.change_item(assigns.item))
     |> assign(:item, assigns.item)
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 4_000_000
     )}
  end

  def render(assigns) do
    ~H"""
    <div id={"edit-timeline-item-#{@item.id}"} class="timeline-item relative w-96">
      <%= StoryWeb.TimelineView.render_item(
          "#{underscore_string(@item.type)}",
          item: @item,
          type: @item.type,
          myself: @myself,
          uploads: @uploads,
          changeset: @changeset) %>
    </div>
    """
  end

  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset =
      socket.assigns.item
      |> Timelines.change_item(item_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    case Timelines.update_item(socket.assigns.item, item_params) do
      {:ok, item} ->
        {:noreply,
          socket
          |> assign(:item, item)
          |> push_event("remove-class", %{selector: "#item-#{item.id}-content", class: "hidden"})
          |> push_event("add-class", %{selector: "#item-#{item.id}-form", class: "hidden"})
          |> assign(:changeset, Timelines.change_item(item))}
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    item = %Timelines.Item{user_id: socket.assigns.current_user_id, id: id}

    Timelines.delete_item(item)

    {:noreply,
     socket
     |> push_event("add-class", %{selector: "#edit-timeline-item-#{id}", class: "hidden"})}
  end
end
