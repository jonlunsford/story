defmodule Story.SOStoryScraper do
  @moduledoc """
  Scraper for Stack Overflow Dev Stories
  """

  def parse_full_document({html, map}) do
    get_name({html, map})
    |> get_job()
    |> get_location()
    |> get_links()
    |> get_rep()
    |> get_intro_statement()
    |> get_tools()
    |> get_technologies()
    |> get_assessments()
    |> get_timeline()
    |> get_reading()
  end

  def get_name({html, map}) do
    [{_tag, _attrs, [name]}] =
      parse_document(html)
      |> Floki.find("#form-section-PersonalInfo div.name h4")

    {html, Map.put(map, :name, name)}
  end

  def get_job({html, map}) do
    [{_tag, _attrs, [job]}] =
      parse_document(html)
      |> Floki.find("#form-section-PersonalInfo div.job")

    {html, Map.put(map, :job, String.trim(job))}
  end

  def get_location({html, map}) do
    [{_tag, _attrs, [job]}] =
      parse_document(html)
      |> Floki.find("div#form-section-PersonalInfo div.ai-center div.wmx2.truncate")

    {html, Map.put(map, :location, String.trim(job))}
  end

  def get_links({html, map}) do
    links =
      parse_document(html)
      |> Floki.find("div#form-section-PersonalInfo a.s-link")
      |> Floki.filter_out("svg")

    list =
      links
      |> Enum.map(fn html ->
        [href] = Floki.attribute(html, "href")
        %{href: href, text: Floki.text(html)}
      end)

    {html, Map.put(map, :links, list)}
  end

  def get_rep({html, map}) do
    parsed =
      parse_document(html)
      |> Floki.find("div#form-section-PersonalInfo div.network-account [title='Stack Overflow']")

    [href] = Floki.attribute(parsed, "href")

    result = %{rep: Floki.text(parsed), href: href}

    {html, Map.put(map, :so, result)}
  end

  def get_intro_statement({html, map}) do
    parsed =
      parse_document(html)
      |> Floki.find("div#form-section-PersonalStatementAndTools span.description-content-full p")
      |> Floki.raw_html(encode: true)

    {html, Map.put(map, :intro_statement, parsed)}
  end

  def get_tools({html, map}) do
    tools =
      parse_document(html)
      |> Floki.find("div#form-section-PersonalStatementAndTools div.tools")
      |> Floki.text()

    {html, Map.put(map, :tools, String.trim(tools))}
  end

  def get_technologies({html, map}) do
    parsed =
      parse_document(html)
      |> Floki.find(
        "div#form-section-TechStack div.user-technologies div.timeline-item-tags span.post-tag"
      )

    tech =
      parsed
      |> Enum.map(fn html ->
        Floki.text(html)
      end)

    {html, Map.put(map, :technologies, tech)}
  end

  def get_assessments({html, map}) do
    logo =
      parse_document(html)
      |> Floki.find("div.js-featured-assessments div.feature-banner--logo img")
      |> then(fn html ->
        [src] = Floki.attribute(html, "src")
        [alt] = Floki.attribute(html, "alt")
        %{img: src, alt: alt}
      end)

    items =
      parse_document(html)
      |> Floki.find(
        "div.js-featured-assessments div.feature-banner--iqs div.feature-banner--items"
      )
      |> Enum.map(fn item ->
        img = Floki.find(item, "a img")
        tag = Floki.find(item, "span.s-tag") |> Floki.text()
        [src] = Floki.attribute(img, "src")
        [alt] = Floki.attribute(img, "alt")

        %{tag: tag, img: src, alt: alt}
      end)

    {html, Map.put(map, :assessments, %{banner_logo: logo, items: items})}
  end

  def get_timeline({html, map}) do
    parsed =
      parse_document(html)
      |> Floki.find("div.timeline-item")
      |> Enum.map(fn item ->
        type = Floki.find(item, "span.timeline-item-type") |> Floki.text()
        [order_by] = Floki.attribute(item, "data-order-by")

        details = parse_timeline_details(item, type)

        %{
          date:
            Floki.find(item, "span.timeline-item-date")
            |> Floki.text(deep: false)
            |> String.trim(),
          description: Floki.find(item, ".description-content-truncated p") |> Floki.raw_html(),
          tags: Floki.find(item, ".s-tag") |> Enum.map(fn tag -> Floki.text(tag) end),
          title: details.title,
          img: details.img,
          location: details.location,
          order_by: order_by,
          type: type,
          url: details.url
        }
      end)

    {html, Map.put(map, :timeline, parsed)}
  end

  def get_reading({html, map}) do
    parsed =
      parse_document(html)
      |> Floki.find(".readings-item")
      |> Enum.map(fn item ->
        title_el = Floki.find(item, ".readings-item-title")
        [url] = Floki.find(title_el, "a") |> Floki.attribute("href")

        %{
          title: Floki.text(title_el),
          url: url,
          author: Floki.find(item, ".readings-item-author") |> Floki.text(),
          description: Floki.find(item, ".description-content-truncated p") |> Floki.raw_html()
        }
      end)

    {html, Map.put(map, :reading, parsed)}
  end

  defp parse_timeline_details(item, _type = "Assessment") do
    img = Floki.find(item, ".timeline-item-text img")
    [alt] = Floki.attribute(img, "alt")
    [src] = Floki.attribute(img, "src")

    %{
      title: alt |> String.trim("Title: "),
      img: src,
      location: nil,
      url: nil
    }
  end

  defp parse_timeline_details(item, _type) do
    title_info =
      case Floki.find(item, ".timeline-item-title")
           |> Floki.text()
           |> String.trim()
           |> String.split("    ") do
        [title, _, location] -> %{title: String.trim(title, " at"), location: location}
        [title] -> %{title: title, location: nil}
        [""] -> %{title: nil, location: nil}
      end

    url =
      case Floki.find(item, ".timeline-item-title a") |> Floki.attribute("href") do
        [href] -> href
        [] -> nil
        _ -> nil
      end

    img =
      case Floki.find(item, ".img.logo img") |> Floki.attribute("src") do
        [src] -> src
        [] -> nil
        _ -> nil
      end

    %{
      title: title_info.title,
      location: title_info.location,
      url: url,
      img: img
    }
  end

  defp parse_document(html) when is_list(html), do: html

  defp parse_document(html) when is_binary(html) do
    {:ok, doc} = Floki.parse_document(html)
    doc
  end
end
