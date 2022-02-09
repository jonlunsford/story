defmodule Story.SOStoryScraper do
  @moduledoc """
  Scraper for Stack Overflow Dev Stories
  """

  def fetch_and_parse_story(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_full_document({body, %{}})

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        %{status: "Not Found"}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        %{status: code}

      {:ok, %HTTPoison.Error{reason: reason}} ->
        %{error: reason}
    end
  end

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
    name =
      parse_document(html)
      |> get_text("#form-section-PersonalInfo div.name h4")

    {html, Map.put(map, :name, name)}
  end

  def get_job({html, map}) do
    job =
      parse_document(html)
      |> get_text("#form-section-PersonalInfo div.job")

    {html, Map.put(map, :job, job)}
  end

  def get_location({html, map}) do
    location =
      parse_document(html)
      |> get_text("div#form-section-PersonalInfo div.ai-center div.wmx2.truncate")

    {html, Map.put(map, :location, location)}
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
    parsed = parse_document(html)

    result =
      case Floki.find(
             parsed,
             "div#form-section-PersonalInfo div.network-account [title='Stack Overflow']"
           ) do
        [] ->
          nil

        el ->
          [href] = Floki.attribute(el, "href")

          %{rep: Floki.text(el), href: href}
      end

    {html, Map.put(map, :so, result)}
  end

  def get_intro_statement({html, map}) do
    parsed =
      parse_document(html)
      |> Floki.find("div#form-section-PersonalStatementAndTools span.description-content-full p")
      |> Floki.raw_html()

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
    parsed = parse_document(html)

    logo =
      case Floki.find(parsed, "div.js-featured-assessments div.feature-banner--logo img") do
        [] ->
          ""

        el ->
          [src] = Floki.attribute(el, "src")
          [alt] = Floki.attribute(el, "alt")
          %{img: src, alt: alt}
      end

    items =
      case Floki.find(
             parsed,
             "div.js-featured-assessments div.feature-banner--iqs div.feature-banner--items"
           ) do
        [] ->
          ""

        els ->
          Enum.map(els, fn item ->
            img = Floki.find(item, "a img")
            tag = Floki.find(item, "span.s-tag") |> Floki.text()
            [src] = Floki.attribute(img, "src")
            [alt] = Floki.attribute(img, "alt")

            %{tag: tag, img: src, alt: alt}
          end)
      end

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

  defp get_text(html, selector) do
    case Floki.find(html, selector) do
      [{_tag, _attrs, [text]}] -> String.trim(text)
      _ -> ""
    end
  end
end
