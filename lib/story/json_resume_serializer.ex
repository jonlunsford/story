defmodule Story.JSONResumeSerializer do
  alias Story.Pages.Page

  def call(%Page{} = page) do
    info = page.personal_information
    {timeline, _} = Enum.group_by(page.timeline_items, fn item ->
      case item.type do
        "Position" -> :work
        "Blogs or videos" -> :publications
        "Top post" -> :publications
        "Feature or Apps" -> :projects
        "Open source" -> :projects
        "Assessment" -> :skills
        _ ->
          item.type
          |> StoryWeb.LayoutView.underscore_string()
          |> String.to_atom()
      end
    end)
    |> Enum.map_reduce(%{}, &map/2)

    timeline_map = Enum.into(timeline, %{})

    %{
      basics: %{
        name: safe_fetch(info, :name),
        label: safe_fetch(info, :job_title),
        image: safe_fetch(info, :picture_url),
        url: safe_fetch(info, :website),
        summary: safe_fetch(info, :statement),
        email: "",
        phone: "",
        location: %{
          city: (if info, do: String.split(info.location, ",") |> List.first() |> String.trim(), else: ""),
          region: (if info, do: String.split(info.location, ",") |> List.last() |> String.trim(), else: ""),
          address: "",
          postal_code: "",
          country_code: ""
        },
        profiles: [
          %{
            network: "Twitter",
            username: safe_fetch(info, :twitter),
            url: "https://twitter.com/#{safe_fetch(info, :twitter)}"
          },
          %{
            network: "GitHub",
            username: safe_fetch(info, :github),
            url: "https://github.com/#{safe_fetch(info, :github)}"
          }
        ]
      },
      languages: [],
      awards: [],
    }
    |> Map.merge(timeline_map)
  end

  defp map(%{work: work} = _items, map) do
    work =
      Enum.map(work, fn(item) ->
        end_date =
          if item.current_position, do: "", else: format_time(item.end_date)

        %{
          name: item.location,
          item: item.title,
          url: item.url,
          start_date: format_time(item.start_date),
          end_date: end_date,
          summary: item.description,
          highlights: Enum.map(item.tags, fn tag -> tag.name end)
        }
      end)

    {{:work, work}, map}
  end

  defp map(%{education: education} = _items, map) do
    ed =
      Enum.map(education, fn(item) ->
        end_date =
          if item.current_position, do: "", else: format_time(item.end_date)

        %{
          institution: item.location,
          url: item.url,
          start_date: format_time(item.start_date),
          end_date: end_date,
          courses: Enum.map(item.tags, fn tag -> tag.name end),
          area: "",
          study_type: "",
          score: "",

        }
      end)

    {{:education, ed}, map}
  end

  defp map(%{publications: publications} = _items, map) do
    pub =
      Enum.map(publications, fn(item) ->
        %{
          name: item.title,
          publisher: item.location,
          release_date: format_time(item.start_date),
          url: item.url,
          summary: item.description,
          tags: Enum.map(item.tags, fn tag -> tag.name end)
        }
      end)

    {{:publications, pub}, map}
  end

  defp map(%{skills: skills} = _items, map) do
    skills =
      Enum.map(skills, fn(item) ->
        %{
          name: item.title,
          level: "",
          date: format_time(item.start_date),
          url: item.url,
          summary: item.description,
          keywords: Enum.map(item.tags, fn tag -> tag.name end)
        }
      end)

    {{:skills, skills}, map}
  end

  defp map(%{projects: projects} = _items, map) do
    projects =
      Enum.map(projects, fn(item) ->
        end_date =
          if item.current_position, do: "", else: format_time(item.end_date)

        %{
          name: item.title,
          description: item.description,
          highlights: "",
          keywords: Enum.map(item.tags, fn tag -> tag.name end),
          start_date: format_time(item.start_date),
          end_date: end_date,
          url: item.url,
          entity: "",
          roles: [],
          type: item.type
        }
      end)

    {{:projects, projects}, map}
  end

  defp map(items, map) do
    {key, values} = items

    items =
      Enum.map(values, fn(item) ->
        end_date =
          if item.current_position, do: "", else: format_time(item.end_date)

        %{
          title: item.title,
          type: item.type,
          url: item.url,
          location: item.location,
          img: item.img,
          description: item.description,
          start_date: format_time(item.start_date),
          end_date: end_date,
          keywords: Enum.map(item.tags, fn tag -> tag.name end)
        }
      end)

    {{key, items}, map}
  end

  defp format_time(nil), do: ""

  defp format_time(naive_date_time) do
    Calendar.strftime(naive_date_time, "%Y-%m-%d")
  end

  defp safe_fetch(nil, _), do: ""

  defp safe_fetch(map, key) when is_map(map) do
    Map.get(map, key)
  end
end
