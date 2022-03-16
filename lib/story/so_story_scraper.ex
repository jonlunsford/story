defmodule Story.SOStoryScraper do
  @moduledoc """
  Scraper for Stack Overflow Dev Stories
  """

  alias Story.Pages.{Page, Reading}
  alias Story.Profiles.Info
  alias Story.Tags
  alias Story.Stats.Stat
  alias Story.Timelines.Item

  def fetch_and_parse(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_full_document({body, %{}})

      {:ok, %HTTPoison.Response{status_code: code}} ->
        %{status: code}

      {:ok, %HTTPoison.Error{reason: reason}} ->
        %{error: reason}
    end
  end

  def fetch_and_save(url, attrs \\ %{}) do
    case fetch_and_parse(url) do
      {_html, map} ->
        map = Map.merge(map, attrs)

        info = save_personal_info(map)
        stats = save_stats(map)
        readings = save_readings(map)
        timeline = save_timeline(map)

        %Page{
          readings: readings,
          stats: stats,
          timeline_items: timeline,
          personal_information: info
        }

      %{status: status} ->
        %{status: status}

      %{error: reason} ->
        %{error: reason}
    end
  end

  def parse_to_structs({html, map}) do
    {_html, map} = parse_full_document({html, map})

    slug = String.downcase(map.name) |> String.replace(" ", "-")

    stats =
      Enum.map(map.assessments.items, fn assessment ->
        %Stat{
          description: assessment.alt,
          title: assessment.alt,
          img: assessment.img,
          type: "assessment",
          tags: [%Tags.Tag{name: assessment.tag}]
        }
      end)

    stats =
      stats ++
        [%Stat{title: "Stack Overflow Reputation", description: map.so.rep, type: "so_rep"}]

    %Page{
      description: "Imported From StackOverflow",
      slug: slug,
      title: "#{map.name}'s DevStory",
      readings: Enum.map(map.reading, fn reading -> struct(%Reading{}, reading) end),
      stats: stats,
      timeline_items: Enum.map(map.timeline, &build_item/1),
      personal_information: build_info(map)
    }
  end

  def build_item(item) do
    tags = Enum.map(item.tags, fn tag -> %Tags.Tag{name: tag} end)
    dates = String.split(item.date, "→") |> Enum.map(fn date -> String.trim(date) end)
    current_position = String.equivalent?(List.last(dates), "Current")

    order_by = convert_order_by_to_db(item.order_by)

    start_date =
      case convert_date_to_db(List.first(dates)) do
        {:ok, naive_start_date} -> naive_start_date
        {:error, :no_date_found} -> order_by
      end

    end_date =
      case convert_date_to_db(List.last(dates)) do
        {:ok, naive_end_date} -> naive_end_date
        {:error, :no_date_found} -> order_by
      end

    item =
      item
      |> Map.put(:tags, tags)
      |> Map.put(:start_date, start_date)
      |> Map.put(:end_date, end_date)
      |> Map.put(:order_tpy, order_by)
      |> Map.put(:current_position, current_position)

    struct(%Item{}, item)
  end

  def build_info(map) do
    tools = String.split(map.tools, "•")

    editor =
      tools
      |> List.first()
      |> String.trim("Favorite editor: ")

    computer =
      tools
      |> List.last()
      |> String.trim(" First computer: ")

    %Info{
      statement: map.intro_statement,
      job_title: map.job,
      name: map.name,
      location: map.location,
      favorite_editor: editor,
      first_computer: computer,
      github: map.github,
      twitter: map.twitter,
      website: map.website,
      picture_url: map.picture_url,
      tags: Enum.map(map.technologies, fn tech -> %Tags.Tag{name: tech} end)
    }
  end

  def parse_full_document({html, map}) do
    get_name({html, map})
    |> get_picture_url()
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

  def save_personal_info(map) do
    tools = String.split(map.tools, "•")

    editor =
      tools
      |> List.first()
      |> String.trim("Favorite editor: ")

    computer =
      tools
      |> List.last()
      |> String.trim(" First computer: ")

    attrs = %{
      statement: map.intro_statement,
      job_title: map.job,
      name: map.name,
      location: map.location,
      favorite_editor: editor,
      first_computer: computer,
      picture_url: map.picture_url,
      twitter: map.twitter,
      github: map.github,
      website: map.website,
      user_id: map.user_id,
      page_id: map.page_id
    }

    tags = Enum.map(map.technologies, fn name -> %{name: name} end)

    Story.Profiles.create_and_tag_info(attrs, tags)
  end

  def save_stats(map) do
    assessment_stats =
      Enum.map(map.assessments.items, fn item ->
        %{
          type: "assessment",
          description: item.alt,
          img: item.img,
          user_id: map.user_id,
          page_id: map.page_id,
          tags: [item.tag]
        }
      end)

    so_rep_stat = %{
      type: "so_reputation",
      description: map.so.rep,
      url: map.so.href,
      user_id: map.user_id,
      page_id: map.page_id,
      tags: []
    }

    all_stats = assessment_stats ++ [so_rep_stat]

    Enum.map(all_stats, fn stat ->
      {tags, attrs} = Map.pop(stat, :tags, [])
      tags = Enum.map(tags, fn tag -> %{name: tag} end)

      Story.Stats.create_and_tag_stat(attrs, tags)
    end)
  end

  def save_readings(map) do
    Enum.map(map.reading, fn reading ->
      attrs =
        reading
        |> Map.put(:user_id, map.user_id)
        |> Map.put(:page_id, map.page_id)

      {:ok, reading} = Story.Pages.create_reading(attrs)
      reading
    end)
  end

  def save_timeline(map) do
    Enum.map(map.timeline, fn item ->
      dates = String.split(item.date, "→") |> Enum.map(fn date -> String.trim(date) end)
      order_by = convert_order_by_to_db(item.order_by)

      start_date =
        case convert_date_to_db(List.first(dates)) do
          {:ok, naive_start_date} -> naive_start_date
          {:error, :no_date_found} -> order_by
        end

      end_date =
        case convert_date_to_db(List.last(dates)) do
          {:ok, naive_end_date} -> naive_end_date
          {:error, :no_date_found} -> order_by
        end

      tags = Enum.map(item.tags, fn tag -> %{name: tag} end)

      Story.Timelines.create_and_tag_item(
        %{
          start_date: start_date,
          end_date: end_date,
          current_position: String.equivalent?(List.last(dates), "Current"),
          description: item.description,
          img: item.img || item.content_img,
          content_img: item.content_img,
          location: item.location,
          order_by: order_by,
          title: item.title,
          type: item.type,
          url: item.url,
          user_id: map.user_id,
          page_id: map.page_id
        },
        tags
      )
    end)
  end

  def get_picture_url({html, map}) do
    parsed = parse_document(html)

    result =
      case Floki.find(parsed, "#form-section-PersonalInfo .bs-md img") do
        [] ->
          nil

        el ->
          [src] = Floki.attribute(el, "src")
          src
      end

    {html, Map.put(map, :picture_url, result)}
  end

  def get_name({html, map}) do
    name =
      parse_document(html)
      |> get_text("#form-section-PersonalInfo div.name h4")

    {html, Map.put(map, :name, name)}
  end

  def get_job({html, page}) do
    job =
      parse_document(html)
      |> get_text("#form-section-PersonalInfo div.job")

    {html, Map.put(page, :job, job)}
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

    github =
      case Enum.find(list, fn link -> String.contains?(link.href, "https://github.com/") end) do
        nil -> nil
        link -> link.text
      end

    twitter =
      case Enum.find(list, fn link -> String.contains?(link.href, "https://twitter.com/") end) do
        nil -> nil
        link -> link.text
      end

    website =
      case Enum.find(list, fn link ->
             !String.contains?(link.href, "twitter.com") &&
               !String.contains?(link.text, "github.com")
           end) do
        nil -> nil
        link -> link.text
      end

    result = %{
      github: github,
      twitter: twitter,
      website: website
    }

    {html, Map.merge(map, result)}
  end

  def get_rep({html, map}) do
    parsed = parse_document(html)

    result =
      case Floki.find(
             parsed,
             "div#form-section-PersonalInfo div.network-account [title='Stack Overflow']"
           ) do
        [] ->
          %{rep: "", href: ""}

        el ->
          [href] = Floki.attribute(el, "href")

          %{rep: Floki.text(el), href: href}
      end

    {html, Map.put(map, :so, result)}
  end

  def get_intro_statement({html, map}) do
    parsed =
      parse_document(html)
      |> Floki.find("div#form-section-PersonalStatementAndTools span.description-content-full *")
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
          %{}

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
          []

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
          description: Floki.find(item, ".description-content-truncated *") |> Floki.raw_html(),
          tags: Floki.find(item, ".s-tag") |> Enum.map(fn tag -> Floki.text(tag) end),
          title: details.title,
          content_img: details.content_img,
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
      url: nil,
      content_img: nil
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

    content_img =
      case Floki.find(item, ".img.full img") |> Floki.attribute("src") do
        [src] -> src
        [] -> nil
        _ -> nil
      end

    %{
      title: title_info.title,
      location: title_info.location,
      url: url,
      img: img,
      content_img: content_img
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

  defp convert_date_to_db("Jan" <> year),
    do: NaiveDateTime.new(parse_year(year), 1, 1, 0, 0, 0)

  defp convert_date_to_db("Feb" <> year),
    do: NaiveDateTime.new(parse_year(year), 2, 1, 0, 0, 0)

  defp convert_date_to_db("Mar" <> year),
    do: NaiveDateTime.new(parse_year(year), 3, 1, 0, 0, 0)

  defp convert_date_to_db("Apr" <> year),
    do: NaiveDateTime.new(parse_year(year), 4, 1, 0, 0, 0)

  defp convert_date_to_db("May" <> year),
    do: NaiveDateTime.new(parse_year(year), 5, 1, 0, 0, 0)

  defp convert_date_to_db("Jun" <> year),
    do: NaiveDateTime.new(parse_year(year), 6, 1, 0, 0, 0)

  defp convert_date_to_db("Jul" <> year),
    do: NaiveDateTime.new(parse_year(year), 7, 1, 0, 0, 0)

  defp convert_date_to_db("Aug" <> year),
    do: NaiveDateTime.new(parse_year(year), 8, 1, 0, 0, 0)

  defp convert_date_to_db("Sep" <> year),
    do: NaiveDateTime.new(parse_year(year), 9, 1, 0, 0, 0)

  defp convert_date_to_db("Oct" <> year),
    do: NaiveDateTime.new(parse_year(year), 10, 1, 0, 0, 0)

  defp convert_date_to_db("Nov" <> year),
    do: NaiveDateTime.new(parse_year(year), 11, 1, 0, 0, 0)

  defp convert_date_to_db("Dec" <> year),
    do: NaiveDateTime.new(parse_year(year), 12, 1, 0, 0, 0)

  defp convert_date_to_db("Current"), do: {:ok, NaiveDateTime.utc_now()}

  defp convert_date_to_db(<<year::binary-size(4)>> = _date) do
    NaiveDateTime.new(parse_year(year), 12, 1, 0, 0, 0)
  end

  defp convert_date_to_db(_), do: {:error, :no_date_found}

  def parse_year(string) do
    string
    |> String.trim()
    |> String.to_integer()
  end

  defp convert_order_by_to_db(string) when is_binary(string) do
    <<year::binary-size(4), month::binary-size(2), day::binary-size(2)>> <> _rest = string

    year = String.to_integer(year)
    month = String.to_integer(month)
    day = String.to_integer(day)

    {:ok, datetime} = NaiveDateTime.new(year, month, day, 0, 0, 0)
    datetime
  end
end
