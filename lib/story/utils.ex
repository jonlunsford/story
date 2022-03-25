defmodule Story.Utils do

  alias Story.{Pages, Profiles, Timelines}

  def convert_page_html(page_id) do
    infos = Profiles.get_infos_by_page_id(page_id)
    timeline_items = Timelines.get_items_by_page_id(page_id)
    readings = Pages.get_readings_by_page_id(page_id)

    Enum.each(infos, fn(info) ->
      case Pandex.html_to_markdown(info.statement) do
        {:ok, statement} ->
          Profiles.update_info(info, %{statement: statement})
        {:error, _} ->
          IO.puts("Error converting info: #{info.id}")
      end
    end)

    Enum.each(timeline_items, fn(item) ->
      case Pandex.html_to_markdown(item.description) do
        {:ok, description} ->
          Timelines.update_item(item, %{description: description})
        {:error, _} ->
          IO.puts("Error converting timeline item: #{item.id}")
      end

    end)

    Enum.each(readings, fn(reading) ->
      case Pandex.html_to_markdown(reading.description) do
        {:ok, description} ->
          Pages.update_reading(reading, %{description: description})
        {:error, _} ->
          IO.puts("Error converting reading: #{reading.id}")
      end
    end)
  end
end
