defmodule StoryWeb.EditInfoLive do
  use StoryWeb, :live_component

  alias Story.Profiles
  alias Phoenix.LiveView.JS

  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 4_000_000
     )}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:info, assigns.info)
     |> assign(:changeset, Profiles.change_info(assigns.info))}
  end

  def render(assigns) do
    ~H"""
    <div class="text-center w-1/2 mx-auto mb-12">
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
    picture_url = get_image_url(socket)
    info = socket.assigns.info

    info_params =
      if picture_url do
        Map.put(info_params, "picture_url", picture_url)
      else
        info_params
      end

    case Profiles.update_info(info, info_params) do
      {:ok, info} ->
        {:noreply,
          socket
          |> assign(:info, info)
          |> push_event("remove-class", %{selector: "#info", class: "hidden"})
          |> push_event("add-class", %{selector: "#edit-info", class: "hidden"})
          |> assign(:changeset, Profiles.change_info(info))}
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp get_image_url(socket) do
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
      dest = Path.join("priv/static/uploads", Path.basename(path)) <> "-" <> entry.client_name

      File.cp!(path, dest)

      {:ok, Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")}
    end)
    |> List.first()
  end
end
