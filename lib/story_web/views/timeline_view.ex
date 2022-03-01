defmodule StoryWeb.TimelineView do
  use StoryWeb, :view
  alias Phoenix.LiveView.JS

  def render_item("assessment", assigns) do
    render("items/assessment.html", assigns)
  end

  def render_item(_, assigns) do
    render("items/default.html", assigns)
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
end
