defmodule StoryWeb.PageView do
  use StoryWeb, :view

  alias Phoenix.LiveView.JS

  import StoryWeb.LayoutView, only: [underscore_string: 1]
end
