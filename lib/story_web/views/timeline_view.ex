defmodule StoryWeb.TimelineView do
  use StoryWeb, :view

  import StoryWeb.LayoutView, only: [capitalize_string: 1, markdown_as_html: 1]

  @available_forms [
    "assessment",
    "blogs_or_videos",
    "default",
    "education",
    "feature_or_apps",
    "open_source",
    "position"
  ]

  @available_types [
    "assessment",
    "blogs_or_videos",
    "default",
    "education",
    "feature_or_apps",
    "open_source",
    "position"
  ]

  def render_form(item_type, assigns) when item_type in @available_forms do
    render("forms/#{item_type}_form.html", assigns)
  end

  def render_form(_item_type, assigns) do
    render("forms/default_form.html", assigns)
  end

  def render_item(item_type, assigns) when item_type in @available_types do
    render("items/#{item_type}.html", assigns)
  end

  def render_item(_, assigns) do
    render("items/default.html", assigns)
  end

  def render_date_display(item) do
    template = determine_date_display_template(item)
    render("shared/_#{template}.html", item: item)
  end

  def year_select_range() do
    cur_year = DateTime.utc_now().year
    (cur_year - 50)..cur_year
  end

  def pretty_time_difference(start_date, end_date, current_position \\ false) do
    end_date =
      cond do
        current_position -> NaiveDateTime.utc_now()
        true -> end_date
      end

    years = Timex.diff(end_date, start_date, :year)
    months = Timex.diff(end_date, start_date, :month) - years * 12 + 1

    years =
      cond do
        months >= 12 -> years + months / 12
        true -> years
      end

    months =
      cond do
        months == 12 -> 0
        true -> months
      end

    years_string =
      cond do
        years == 0 -> nil
        years > 1 -> "#{years} years"
        true -> "#{years} year"
      end

    months_string =
      cond do
        months == 0 -> nil
        months > 1 -> "#{months} months"
        true -> "#{months} month"
      end

    cond do
      years_string == nil -> "(#{months_string})"
      months_string == nil -> "(#{years_string})"
      true -> "(#{years_string}, #{months_string})"
    end
  end

  def order_timeline(timeline_items) do
    Enum.sort_by(
      timeline_items,
      &convert_date_time(&1),
      {:desc, Date}
    )
  end

  def group_timeline_for_csv(timeline_items) do
    timeline_items
    |> order_timeline()
    |> Enum.group_by(fn item ->
      case item.type do
        "Position" -> " Experience"
        "Feature or Apps" -> "Apps & Software"
        _ -> "Public Artifacts"
      end
    end)
  end

  def get_image(item) do
    cond do
      item.img -> item.img
      item.content_img -> item.content_img
      true -> nil
    end
  end

  defp convert_date_time(%{current_position: true}) do
    NaiveDateTime.utc_now()
  end

  defp convert_date_time(%{order_by: nil}) do
    NaiveDateTime.utc_now()
  end

  defp convert_date_time(%{order_by: order_by} = item) when is_binary(order_by) do
    item.end_date || item.start_date || NaiveDateTime.utc_now()
  end

  defp convert_date_time(%{order_by: order_by}) do
    NaiveDateTime.to_date(order_by)
  end

  defp determine_date_display_template(%{start_date: nil} = _item) do
    "date_display_single"
  end

  defp determine_date_display_template(%{end_date: nil} = _item) do
    "date_display_single"
  end

  defp determine_date_display_template(item) do
    case NaiveDateTime.compare(item.start_date, item.end_date) do
      :eq -> "date_display_year"
      _ -> "date_display_range"
    end
  end
end
