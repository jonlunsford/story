defmodule StoryWeb.UserRegistrationView do
  use StoryWeb, :view
  alias Phoenix.LiveView.JS

  def render_form(assigns \\ %{}, block) do
    assigns =
      assigns
      |> Map.new()
      |> Map.put(:inner_content, block)

    render("_form.html", assigns)
  end
end
