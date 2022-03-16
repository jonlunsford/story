defmodule StoryWeb.NewLive do
  use StoryWeb, :live_view
import StoryWeb.LayoutView, only: [underscore_string: 1]
  import StoryWeb.TimelineView, only: [order_timeline: 1]

  alias Story.Accounts
  alias Story.{Pages, Profiles}

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    page = create_or_find_page(current_user)

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
      <div class="py-8">
        <div class="divider my-8 w-1/2 mx-auto text-secondary">Personal Information</div>

        <p class="mt-4 text-secondary text-sm w-1/4 mx-auto text-center mb-8">Add some details about yourself so prospective employers can get to know you.</p>

        <.live_component
          module={StoryWeb.EditInfoLive}
          id={"info-#{@page.personal_information.id}"}
          current_user_id={@current_user_id}
          page_id={@page.id}
          info={@page.personal_information} />

        <%= if Enum.any?(@page.stats) do %>
          <div class="divider my-8 w-1/2 mx-auto text-secondary">Assessments</div>

          <div class="mt-8 mb-12 flex flex-wrap justify-center">
            <%= for stat <-  @page.stats do %>
              <%= StoryWeb.StatView.render_stat("#{underscore_string(stat.type)}", stat: stat) %>
            <% end %>
          </div>
        <% end %>

        <div class="divider my-8 w-1/4 mx-auto text-secondary">Timeline</div>

        <p class="mt-4 text-secondary text-sm text-center w-1/4 mx-auto">Add items to your timeline that tells your story as a developer.</p>

        <div class="min-h-full relative mt-8 mt-16 mx-auto" style="width: 815px;">
          <div class="w-px absolute top-0 left-1/2 border h-full"></div>

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

        <div class="relative mx-auto mt-24" style="width: 800px;">
          <div class="divider my-12 w-1/2 mx-auto text-secondary">Recommended Reading</div>

          <div class="grid grid-cols-3 gap-4 mx-auto mb-8" style="width: 800px;">
            <%= for reading <- @readings do %>
              <.live_component
                id={"reading-#{reading.id}"}
                module={StoryWeb.EditReadingLive}
                reading={reading}
                current_user_id={@current_user_id} />
            <% end %>
          </div>

          <p class="text-secondary text-sm text-center w-1/2 mx-auto mb-8">What are some of your favorite readings? Highlight anything you've read that will help potential employers learn more about what you're learning.</p>

          <.live_component
            id="add-new-reading"
            current_user_id={@current_user_id}
            page_id={@page.id}
            module={StoryWeb.AddNewReadingLive} />
        </div>
      </div>
    <% end %>
    """
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
        slug: current_user.slug || "story-#{current_user.id}",
        title: "My DevStory",
        user_id: current_user.id
      })
      |> Story.Repo.preload(
        personal_information: [:tags],
        stats: [:tags],
        timeline_items: [:tags],
        readings: []
      )

    {_, page} =
      Map.get_and_update(page, :personal_information, fn(current_value) ->
        case current_value do
          nil -> {current_value, %Profiles.Info{user_id: current_user.id, page_id: page.id, tags: []}}
          _ -> {current_value, current_value}
        end
      end)

    page
  end
end
