defmodule StoryWeb.PageView do
  use StoryWeb, :view

  alias Phoenix.LiveView.JS

  import StoryWeb.LayoutView, only: [underscore_string: 1, dasherize_string: 1, markdown_as_html: 1]
  import StoryWeb.TimelineView, only: [order_timeline: 1, group_timeline_for_csv: 1, timeline_span: 1]

  def toggle_cv_item_text_on(title) do
    "Show More #{String.trim(title)}"
  end

  def toggle_cv_item_text_off(title) do
    "Show Less #{String.trim(title)}"
  end
end
