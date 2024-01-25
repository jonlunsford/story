defmodule Story.JSONResumeSerializerTest do
  use Story.DataCase

  alias Story.JSONResumeSerializer
  alias Story.SOStoryScraper

  setup do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    page = SOStoryScraper.parse_to_structs({html, %{}})

    {:ok, %{page: page}}
  end

  test "it serializes basics", %{page: page} do
    info = page.personal_information

    assert JSONResumeSerializer.call(page).basics == %{
             name: info.name,
             label: info.job_title,
             image: info.picture_url,
             url: info.website,
             summary: info.statement,
             email: "",
             phone: "",
             location: %{
               city: "San Luis Obispo",
               region: "CA",
               address: "",
               postal_code: "",
               country_code: ""
             },
             profiles: [
               %{
                 network: "Twitter",
                 username: "jonlunsford1",
                 url: "https://twitter.com/#{info.twitter}"
               },
               %{
                 network: "GitHub",
                 username: "jonlunsford",
                 url: "https://github.com/#{info.github}"
               }
             ]
           }
  end

  test "it handles nil personal_information", %{page: page} do
    page = Map.put(page, :personal_information, nil)

    assert JSONResumeSerializer.call(page).basics == %{
             name: "",
             label: "",
             image: "",
             url: "",
             summary: "",
             email: "",
             phone: "",
             location: %{
               city: "",
               region: "",
               address: "",
               postal_code: "",
               country_code: ""
             },
             profiles: [
               %{
                 network: "Twitter",
                 username: "",
                 url: "https://twitter.com/"
               },
               %{
                 network: "GitHub",
                 username: "",
                 url: "https://github.com/"
               }
             ]
           }
  end

  test "it handles missing personal_information.location", %{page: page} do
    page = Map.put(page, :personal_information, %{location: nil})

    assert JSONResumeSerializer.call(page).basics == %{
             name: "",
             label: "",
             image: "",
             url: "",
             summary: "",
             email: "",
             phone: "",
             location: %{
               city: "",
               region: "",
               address: "",
               postal_code: "",
               country_code: ""
             },
             profiles: [
               %{
                 network: "Twitter",
                 username: "",
                 url: "https://twitter.com/"
               },
               %{
                 network: "GitHub",
                 username: "",
                 url: "https://github.com/"
               }
             ]
           }
  end

  test "it serializes work", %{page: page} do
    assert List.first(JSONResumeSerializer.call(page).work) == %{
             end_date: "",
             start_date: "2017-01-01",
             url: "https://stackoverflow.com/users/story/lists/111124/convertkit?storyType=1",
             description:
               "<p>Engineering highly concurrent and reliable systems ensuring millions of transactions per day. Tech Lead of Compliance/Fraud prevention.</p>",
             img:
               "https://crunchbase-production-res.cloudinary.com/image/upload/h_90/v1427187432/b4psrtucrimobg8y8z0i.png",
             keywords: [
               "ruby",
               "ruby-on-rails",
               "elixir",
               "redis",
               "sidekiq",
               "amazon-web-services",
               "heroku",
               "github",
               "go",
               "mysql",
               "postgresql",
               "cassandra",
               "elasticsearch",
               "backend"
             ],
             location: "ConvertKit",
             title: "Sr. Engineer",
             type: "Position"
           }
  end

  defp load_file(relative_path) do
    (File.cwd!() <> relative_path)
    |> Path.expand(relative_path)
    |> Path.absname()
    |> File.read()
  end
end
