defmodule StoryWeb.EditLive do
  use StoryWeb, :live_view

  import StoryWeb.LayoutView, only: [underscore_string: 1]
  import StoryWeb.TimelineView, only: [order_timeline: 1]

  alias Story.Accounts
  alias Story.{Pages, Profiles}

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    page =
      case Pages.get_user_latest_page(current_user) do
        nil -> create_or_find_page(current_user)
        page -> page_with_added_info(page, current_user)
      end

    {:ok,
     socket
     |> assign(:current_user_id, current_user.id)
     |> assign(:timeline_items, page.timeline_items)
     |> assign(:readings, page.readings)
     |> assign(:page, page)}
  end

  def render(assigns) do
    ~H"""
    <%= if @page do %>
      <div class="mt-8 relative">

        <div class="md:absolute mb-8 top-0 right-0 lg:w-1/8">
          <a href={"/#{@page.slug}"} class="btn btn-block btn-sm btn-outline rounded-none">Live Preview</a>
          <a href="/users/settings" class="btn btn-block border-t-0 btn-sm btn-outline rounded-none">Change URL</a>

          <.form for={:published} phx-change="toggle-published" as="page">
            <div class="form-control">
              <label class="label cursor-pointer">
                <span class="label-text">Published?</span>
                <input name="published" type="checkbox" checked={@page.published} class="checkbox">
              </label>
            </div>
          </.form>
        </div>

        <div class="px-8 md:px-0 md:w-46 mx-auto mb-12">
          <.live_component
            module={StoryWeb.EditInfoLive}
            current_user_id={@current_user_id}
            id={"info-#{@page.personal_information.id}"}
            page_id={@page.id}
            info={@page.personal_information} />

          <%= if Enum.any?(@page.stats) do %>
            <h3 class="text-neutral font-extrabold text-2xl mt-8">Assessments <span class="text-xs italic text-gray-400">By Pluralsight IQ</span></h3>

            <div class="mt-2 mb-12 flex flex-wrap justify-start">
              <%= for stat <-  @page.stats do %>
                <%= StoryWeb.StatView.render_stat("#{underscore_string(stat.type)}", stat: stat) %>
              <% end %>
            </div>
          <% end %>
        </div>


        <div class="min-h-full relative mt-8 pt-16 mx-auto md:w-815px">
          <div class="timeline-line w-px absolute top-0 left-1/2 border h-full"></div>

          <.live_component
            module={StoryWeb.AddNewTimelineItemLive}
            id="add-new-item"
            current_user_id={@current_user_id}
            page_id={@page.id} />

          <%= for item <- order_timeline(@timeline_items) do %>
            <.live_component
              module={StoryWeb.EditTimelineItemLive}
              current_user_id={@current_user_id}
              id={"timeline-#{item.id}"}
              item={item} />
          <% end %>
        </div>

        <div class="px-8 md:px-0 md:w-46 mx-auto mb-12 mt-24 relative">
          <h3 class="text-neutral font-extrabold text-2xl mb-8">Recommended Reading</h3>

          <.live_component
            id="add-new-reading"
            current_user_id={@current_user_id}
            page_id={@page.id}
            module={StoryWeb.AddNewReadingLive} />

          <div class="">
            <%= for reading <- @readings do %>
              <.live_component
                id={"reading-#{reading.id}"}
                module={StoryWeb.EditReadingLive}
                reading={reading}
                current_user_id={@current_user_id} />
            <% end %>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  def handle_event("toggle-published", %{"_target" => ["published"], "published" => "on"}, socket) do
    Pages.update_page(socket.assigns.page, %{published: true})

    {:noreply, socket}
  end

  def handle_event("toggle-published", %{"_target" => ["published"]}, socket) do
    Pages.update_page(socket.assigns.page, %{published: false})

    {:noreply, socket}
  end

  def handle_info({:added_item, item}, socket) do
    items = socket.assigns.timeline_items ++ [item]

    {:noreply, assign(socket, :timeline_items, items)}
  end

  def handle_info({:added_reading, reading}, socket) do
    readings = socket.assigns.readings ++ [reading]

    {:noreply, assign(socket, :readings, readings)}
  end

  defp create_or_find_page(current_user) do
    page =
      Pages.create_or_find_page(%{
        description: "DevStory",
        slug: current_user.slug || SecureRandom.uuid <> "-" <> Integer.to_string(current_user.id),
        title: "My DevStory",
        user_id: current_user.id
      })
      |> Story.Repo.preload(
        personal_information: [:tags],
        stats: [:tags],
        timeline_items: [:tags],
        readings: []
      )

    page_with_added_info(page, current_user)
  end

  defp page_with_added_info(page, current_user) do
    {_, page} =
      Map.get_and_update(page, :personal_information, fn(current_value) ->
        case current_value do
          nil -> {current_value, %Profiles.Info{id: nil, user_id: current_user.id, page_id: page.id, tags: []}}
          _ -> {current_value, current_value}
        end
      end)

    page
  end
end
