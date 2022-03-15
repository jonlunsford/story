defmodule StoryWeb.EditLive do
  use StoryWeb, :live_view

  import StoryWeb.LayoutView, only: [underscore_string: 1]
  import StoryWeb.TimelineView, only: [order_timeline: 1]

  alias Story.Accounts
  alias Story.Pages

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    page = Pages.get_user_latest_page(current_user)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:timeline_items, page.timeline_items)
     |> assign(:page, page)}
  end

  def render(assigns) do
    ~H"""
    <%= if @page do %>
      <div class="mt-8">
        <.live_component
          module={StoryWeb.EditInfoLive}
          id={"info-#{@page.personal_information.id}"}
          info={@page.personal_information} />

        <div class="divider my-8 w-1/2 mx-auto text-secondary">Assessments</div>

        <div class="mt-8 mb-12 flex flex-wrap justify-center">
          <%= for stat <-  @page.stats do %>
            <%= StoryWeb.StatView.render_stat("#{underscore_string(stat.type)}", stat: stat) %>
          <% end %>
        </div>

        <div class="divider my-8 w-1/4 mx-auto text-secondary">Timeline</div>

        <div class="min-h-full relative mt-8 mt-16 mx-auto" style="width: 815px;">
          <div class="w-px absolute top-0 left-1/2 border h-full"></div>

          <.live_component
            module={StoryWeb.AddNewTimelineItemLive}
            id="add-new-item"
            current_user_id={@current_user.id}
            page_id={@page.id} />

          <%= for item <- order_timeline(@timeline_items) do %>
            <.live_component
              module={StoryWeb.EditTimelineItemLive}
              current_user_id={@current_user.id}
              id={"timeline-#{item.id}"}
              item={item} />
          <% end %>
        </div>

        <div class="relative mx-auto" style="width: 800px;">
          <div class="divider my-12 w-1/2 mx-auto text-secondary">Recommended Reading</div>

          <div class="grid grid-cols-3 gap-4 mx-auto mb-12" style="width: 800px;">
            <%= for reading <- @page.readings do %>
              <.live_component
                id={"reading-#{reading.id}"}
                module={StoryWeb.EditReadingLive}
                reading={reading}
                current_user={@current_user} />

            <% end %>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  def handle_info({:added_item, item}, socket) do
    items = socket.assigns.timeline_items ++ [item]

    {:noreply, assign(socket, :timeline_items, items)}
  end
end
