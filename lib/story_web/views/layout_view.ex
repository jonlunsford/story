defmodule StoryWeb.LayoutView do
  use StoryWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def gravatar_for(email, params \\ nil) when is_binary(email) do
    hash =
      :crypto.hash(:md5, email)
      |> Base.encode16(case: :lower)

    "https://www.gravatar.com/avatar/#{hash}?#{params}"
  end

  def dasherize_string(string) when is_binary(string) do
    string
    |> String.replace(" ", "-")
    |> String.downcase()
  end

  def underscore_string(string) when is_binary(string) do
    string
    |> String.replace(" ", "_")
    |> String.downcase()
  end
end
