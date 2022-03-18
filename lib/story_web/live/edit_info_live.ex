defmodule StoryWeb.EditInfoLive do
  use StoryWeb, :live_component

  alias Story.Profiles
  alias Story.S3UploadHelpers

  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 4_000_000,
       external: &presign_upload/2
     )}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:page_id, assigns.page_id)
     |> assign(:current_user_id, assigns.current_user_id)
     |> assign(:info, assigns.info)
     |> assign(:changeset, Profiles.change_info(assigns.info))}
  end

  def render(assigns) do
    ~H"""
    <div class="text-center md:w-1/2 mx-4 md:mx-auto mx-auto mb-12">
      <%= StoryWeb.PageView.render(
        "edit_info_form.html",
        changeset: @changeset,
        uploads: @uploads,
        myself: @myself,
        info: @info) %>

      <%= StoryWeb.PageView.render("edit_info.html", info: @info) %>
    </div>
    """
  end

  def handle_event("validate", %{"info" => info_params}, socket) do
    changeset =
      %Profiles.Info{}
      |> Profiles.change_info(info_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"info" => info_params}, socket) do
    picture_url = S3UploadHelpers.get_image_url(socket)
    info = socket.assigns.info

    info_params =
      if picture_url do
        Map.put(info_params, "picture_url", picture_url)
      else
        info_params
      end

    info_params =
      info_params
      |> Map.put("user_id", socket.assigns.current_user_id)
      |> Map.put("page_id", socket.assigns.page_id)

    case create_or_update(info, info_params) do
      {:ok, info} ->

        info = Story.Repo.preload(info, [:tags])

        {:noreply,
         socket
         |> assign(:info, info)
         |> push_event("remove-class", %{selector: "#info", class: "hidden"})
         |> push_event("add-class", %{selector: "#edit-info", class: "hidden"})
         |> push_event("add-class", %{selector: ".add-info-callout", class: "hidden"})
         |> assign(:changeset, Profiles.change_info(info))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp create_or_update(info, info_params) do
    case info.id do
      nil ->
        Profiles.create_info(info_params)
      _ ->
        Profiles.update_info(info, info_params)
    end
  end

  defp presign_upload(entry, socket) do
    S3UploadHelpers.presign_upload(entry, socket, :avatar)
  end
end
