defmodule StoryWeb.TimelineView do
  use StoryWeb, :view

  @available_forms [
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

  def pretty_time_difference(start_date, end_date) do
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
      &(convert_date_time(&1.order_by)),
      {:desc, Date}
    )
  end

  def get_image(item) do
    cond do
      item.img -> item.img
      item.content_img -> item.content_img
      true -> ""
    end
  end

  defp convert_date_time(nil) do
    NaiveDateTime.utc_now()
  end

  defp convert_date_time(naive_date_time) do
    NaiveDateTime.to_date(naive_date_time)
  end

  defp determine_date_display_template(%{start_date: nil} = item) do
    "date_display_single"
  end

  defp determine_date_display_template(%{end_date: nil} = item) do
    "date_display_single"
  end

  defp determine_date_display_template(item) do
    case NaiveDateTime.compare(item.start_date, item.end_date) do
      :eq -> "date_display_year"
      _ -> "date_display_range"
    end
  end
end
