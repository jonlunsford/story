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
     |> assign(:current_user_id, current_user.id)
     |> assign(:timeline_items, page.timeline_items)
     |> assign(:page, page)}
  end

  def render(assigns) do
    ~H"""
    <%= if @page do %>
      <div class="mt-8 relative">

        <div class="md:absolute mb-8 top-0 right-0 lg:w-1/8">
          <a href={"/#{@page.slug}"} class="btn btn-block btn-sm btn-outline rounded-none">Live Preview</a>
        </div>

        <.live_component
          module={StoryWeb.EditInfoLive}
          current_user_id={@current_user_id}
          id={"info-#{@page.personal_information.id}"}
          page_id={@page.id}
          info={@page.personal_information} />

        <%= if Enum.any?(@page.stats) do %>
          <div class="divider my-8 w-1/2 mx-auto text-neutral">Assessments</div>

          <div class="mt-8 mb-12 flex flex-wrap justify-center">
            <%= for stat <-  @page.stats do %>
              <%= StoryWeb.StatView.render_stat("#{underscore_string(stat.type)}", stat: stat) %>
            <% end %>
          </div>
        <% end %>

        <div class="divider my-8 w-3/4 md:w-1/4 mx-auto text-neutral">Timeline</div>

        <div class="min-h-full relative mt-8 pt-16 mx-auto md:w-815px">
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

        <div class="relative mx-auto md:w-800px">
          <div class="divider my-12 w-3/4 md:w-1/2 mx-auto text-neutral">Recommended Reading</div>

          <.live_component
            id="add-new-reading"
            current_user_id={@current_user_id}
            page_id={@page.id}
            module={StoryWeb.AddNewReadingLive} />

          <div class="md:grid md:grid-cols-3 px-8 md:px-0 space-y-4 md:gap-4 mx-auto mb-12 md:w-800px">
            <%= for reading <- @page.readings do %>
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

  def handle_info({:added_item, item}, socket) do
    items = socket.assigns.timeline_items ++ [item]

    {:noreply, assign(socket, :timeline_items, items)}
  end
end
