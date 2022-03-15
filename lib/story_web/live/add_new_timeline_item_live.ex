defmodule StoryWeb.AddNewTimelineItemLive do
  use StoryWeb, :live_component

  alias Phoenix.LiveView.JS
  alias Story.Timelines
  alias Story.S3UploadHelpers

  def update(assigns, socket) do
    item = %Timelines.Item{ id: "new", type: nil, tags: [], }

    {:ok,
     socket
     |> assign(:form, nil)
     |> assign(:type, nil)
     |> assign(:new_changeset, Timelines.change_item(item))
     |> assign(:user_id, assigns.current_user_id)
     |> assign(:page_id, assigns.page_id)
     |> assign(:item, item)
     |> allow_upload(:img,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 4_000_000,
       external: &presign_upload/2
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="timeline-item add-new">

      <%= @form %>
      <%= StoryWeb.TimelineView.render_form(
          "#{@form}",
          changeset: @new_changeset,
          item: @item,
          uploads: @uploads,
          on_cancel: &hide_form/1,
          myself: @myself) %>

      <div id="item-new-content">
        <header class="text-xs text-secondary mb-6 flex items-center justify-between">
          <strong>Add a new item</strong>
        </header>

        <div class="grid grid-cols-4 gap-4 max-w-full">
          <a class="text-center text-secondary text-xs" href="#" phx-click="show-form" phx-value-type="position" phx-value-form="position" phx-target={@myself}>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M6 6V5a3 3 0 013-3h2a3 3 0 013 3v1h2a2 2 0 012 2v3.57A22.952 22.952 0 0110 13a22.95 22.95 0 01-8-1.43V8a2 2 0 012-2h2zm2-1a1 1 0 011-1h2a1 1 0 011 1v1H8V5zm1 5a1 1 0 011-1h.01a1 1 0 110 2H10a1 1 0 01-1-1z" clip-rule="evenodd" /> <path d="M2 13.692V16a2 2 0 002 2h12a2 2 0 002-2v-2.308A24.974 24.974 0 0110 15c-2.796 0-5.487-.46-8-1.308z" />
            </svg><br />
            Position
          </a>

          <a class="text-center text-secondary text-xs" href="#" phx-click="show-form" phx-value-type="blogs_or_videos" phx-value-form="blogs_or_videos" phx-target={@myself}>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M18 5v8a2 2 0 01-2 2h-5l-5 4v-4H4a2 2 0 01-2-2V5a2 2 0 012-2h12a2 2 0 012 2zM7 8H5v2h2V8zm2 0h2v2H9V8zm6 0h-2v2h2V8z" clip-rule="evenodd" />
            </svg><br />
            Blogs<br />or Videos
          </a>

          <a class="text-center text-secondary text-xs" href="#" phx-click="show-form" phx-value-type="open_source" phx-value-form="open_source" phx-target={@myself}>
            <svg xmlns="http://www.w3.org/2000/svg" class="inline h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M2 5a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V5zm3.293 1.293a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 01-1.414-1.414L7.586 10 5.293 7.707a1 1 0 010-1.414zM11 12a1 1 0 100 2h3a1 1 0 100-2h-3z" clip-rule="evenodd" />
            </svg><br />
            Open<br /> source
          </a>

          <a class="text-center text-secondary text-xs" href="#" phx-click="show-form" phx-value-type="feature_or_apps" phx-value-form="feature_or_apps" phx-target={@myself}>
            <svg xmlns="http://www.w3.org/2000/svg" class="inline h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M12.316 3.051a1 1 0 01.633 1.265l-4 12a1 1 0 11-1.898-.632l4-12a1 1 0 011.265-.633zM5.707 6.293a1 1 0 010 1.414L3.414 10l2.293 2.293a1 1 0 11-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0zm8.586 0a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 11-1.414-1.414L16.586 10l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg><br />
            Feature<br /> or Apps
          </a>

          <a class="text-center text-secondary text-xs" href="#" phx-click="show-form" phx-value-type="education" phx-value-form="education" phx-target={@myself}>
            <svg xmlns="http://www.w3.org/2000/svg" class="inline h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path d="M10.394 2.08a1 1 0 00-.788 0l-7 3a1 1 0 000 1.84L5.25 8.051a.999.999 0 01.356-.257l4-1.714a1 1 0 11.788 1.838L7.667 9.088l1.94.831a1 1 0 00.787 0l7-3a1 1 0 000-1.838l-7-3zM3.31 9.397L5 10.12v4.102a8.969 8.969 0 00-1.05-.174 1 1 0 01-.89-.89 11.115 11.115 0 01.25-3.762zM9.3 16.573A9.026 9.026 0 007 14.935v-3.957l1.818.78a3 3 0 002.364 0l5.508-2.361a11.026 11.026 0 01.25 3.762 1 1 0 01-.89.89 8.968 8.968 0 00-5.35 2.524 1 1 0 01-1.4 0zM6 18a1 1 0 001-1v-2.065a8.935 8.935 0 00-2-.712V17a1 1 0 001 1z" />
            </svg><br />
            Education
          </a>

          <a class="text-center text-secondary text-xs" href="#" phx-click="show-form" phx-value-type="certification" phx-value-form="default"  phx-target={@myself}>
            <svg xmlns="http://www.w3.org/2000/svg" class="inline h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
            </svg><br />
            Certification
          </a>

          <a class="text-center text-secondary text-xs" href="#" phx-click="show-form" phx-value-type="assessment" phx-value-form="default" phx-target={@myself}>
            <svg xmlns="http://www.w3.org/2000/svg" class="inline h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M5 3a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2V5a2 2 0 00-2-2H5zm9 4a1 1 0 10-2 0v6a1 1 0 102 0V7zm-3 2a1 1 0 10-2 0v4a1 1 0 102 0V9zm-3 3a1 1 0 10-2 0v1a1 1 0 102 0v-1z" clip-rule="evenodd" />
            </svg><br />
            Assessment
          </a>

          <a class="text-center text-secondary text-xs" href="#" phx-click="show-form" phx-value-type="milestone" phx-value-form="default" phx-target={@myself}>
            <svg xmlns="http://www.w3.org/2000/svg" class="inline h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg><br />
            Milestone
          </a>
        </div>
      </div>
    </div>

    """
  end

  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset =
      socket.assigns.item
      |> Timelines.change_item(item_params)
      |> Map.put(:action, :insert)

    {:noreply,
     socket
     |> push_event("remove-class", %{selector: "#item-new-form", class: "hidden"})
     |> push_event("add-class", %{selector: "#item-new-content", class: "hidden"})
     |> assign(:new_changeset, changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    picture_url = S3UploadHelpers.get_image_url(socket, :img)

    item_params =
      if picture_url do
        Map.put(item_params, "img", picture_url)
      else
        item_params
      end

    order_by =
      Map.get(item_params, "end_date") || Map.get(item_params, "start_date")

    item_params =
      item_params
      |> Map.put_new("user_id", socket.assigns.user_id)
      |> Map.put_new("page_id", socket.assigns.page_id)
      |> Map.put_new("type", socket.assigns.type)
      |> Map.put_new("order_by", order_by)

    case Timelines.create_item(item_params) do
      {:ok, item} ->
        item = Story.Repo.preload(item, :tags)

        send(self(), {:added_item, item})

        {:noreply,
         socket
         |> assign(:item, item)
         |> push_event("remove-class", %{selector: "#item-new-content", class: "hidden"})
         |> push_event("add-class", %{selector: "#item-orm", class: "hidden"})}

      {:error, changeset} ->
        {:noreply,
         socket
         |> push_event("remove-class", %{selector: ".item-form", class: "hidden"})
         |> push_event("add-class", %{selector: "#item-new-content", class: "hidden"})
         |> assign(:new_changeset, changeset)}
    end
  end

  def handle_event("show-form", %{"form" => form, "type" => type}, socket) do
    item = socket.assigns.item

    {:noreply,
     socket
     |> assign(:form, form)
     |> assign(:type, type)
     |> assign(:new_changeset, Timelines.change_item(item))
     |> push_event("remove-class", %{selector: ".item-form", class: "hidden"})
     |> push_event("add-class", %{selector: "#item-new-content", class: "hidden"})}
  end

  def hide_form(_item, js \\ %JS{}) do
    js
    |> JS.remove_class("hidden", to: "#item-new-content")
    |> JS.add_class("hidden", to: ".item-form")
  end

  defp presign_upload(entry, socket) do
    S3UploadHelpers.presign_upload(entry, socket, :img)
  end
end
