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

  def user_identity(current_user) do
    email = current_user.email

    info =
      Story.Profiles.get_current_info_by_user_id(current_user.id)
      |> Map.put_new(:picture_url, gravatar_for(email))

    %{
      email: email,
      name: info.name,
      picture_url: info.picture_url,
      id: current_user.id,
      created: current_user.inserted_at
    }
  end

  def comma_list_to_tags(string, css_class \\ "p-3") do
    string
    |> String.split(",")
    |> Enum.map(fn tag ->
      content_tag(:span, tag, class: "badge badge-neutral badge-outline rounded-md mb-1 mr-1 " <> css_class)
    end)
  end

  def dasherize_string(nil), do: nil
  def dasherize_string(string) when is_binary(string) do
    string
    |> String.replace(" ", "-")
    |> String.replace("_", "-")
    |> String.downcase()
  end

  def underscore_string(nil), do: nil
  def underscore_string(string) when is_binary(string) do
    string
    |> String.replace(" ", "_")
    |> String.replace("-", "_")
    |> String.downcase()
  end

  def capitalize_string(nil), do: nil
  def capitalize_string(string) when is_binary(string) do
    string
    |> String.replace("-", " ")
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  def markdown_as_html(nil), do: ""

  def markdown_as_html(html, module \\ Application.get_env(:story, :doc_lib, Pandex)) do
    case module.markdown_to_html(html) do
      {:ok, html} ->
        html

      {:error, _reason} ->
        html
    end
  end
end
