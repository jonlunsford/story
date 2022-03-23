defmodule Story.SOStoryScraperTest do
  use ExUnit.Case, async: true

  alias Story.SOStoryScraper

  import Story.AccountsFixtures
  import Story.PagesFixtures

  setup_all do
    user = user_fixture()
    page = page_fixture(%{user_id: user.id})

    {:ok, %{user_id: user.id, page_id: page.id}}
  end

  test "it parses an entire document" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.parse_full_document({html, %{}})

    assert Map.keys(result) == [
             :assessments,
             :github,
             :intro_statement,
             :job,
             :location,
             :name,
             :picture_url,
             :reading,
             :so,
             :technologies,
             :timeline,
             :tools,
             :twitter,
             :website
           ]
  end

  test "it parses to changesets" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    result = SOStoryScraper.parse_to_structs({html, %{}})

    assert %Story.Pages.Page{} = result
  end

  test "it saves personal info", %{user_id: user_id, page_id: page_id} do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")

    {_html, parsed} =
      SOStoryScraper.parse_full_document({html, %{user_id: user_id, page_id: page_id}})

    assert %Story.Profiles.Info{} = SOStoryScraper.save_personal_info(parsed)
  end

  test "it saves stats", %{user_id: user_id, page_id: page_id} do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")

    {_html, parsed} =
      SOStoryScraper.parse_full_document({html, %{user_id: user_id, page_id: page_id}})

    result = SOStoryScraper.save_stats(parsed)

    assert %Story.Stats.Stat{} = List.first(result)
  end

  test "it saves readings", %{user_id: user_id, page_id: page_id} do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")

    {_html, parsed} =
      SOStoryScraper.parse_full_document({html, %{user_id: user_id, page_id: page_id}})

    result = SOStoryScraper.save_readings(parsed)

    assert %Story.Pages.Reading{} = List.first(result)
  end

  test "it saves timelines", %{user_id: user_id, page_id: page_id} do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")

    {_html, parsed} =
      SOStoryScraper.parse_full_document({html, %{user_id: user_id, page_id: page_id}})

    result = SOStoryScraper.save_timeline(parsed)

    assert %Story.Timelines.Item{} = List.first(result)
  end

  test "it gets the name" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_name({html, %{}})

    assert result == %{name: "Jon Lunsford"}
  end

  test "it gets the job" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_job({html, %{}})

    assert result == %{job: "Engineer @convertkit"}
  end

  test "it gets the location" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_location({html, %{}})

    assert result == %{location: "San Luis Obispo, CA"}
  end

  test "it gets the links" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_links({html, %{}})

    assert result == %{
             website: "http://www.capturethecastle.net",
             twitter: "jonlunsford1",
             github: "jonlunsford"
           }
  end

  test "it gets SO info" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_rep({html, %{}})

    assert result == %{
             so: %{rep: "255", href: "https://stackoverflow.com/users/823967"}
           }
  end

  test "it gets the intro statement" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_intro_statement({html, %{}})

    assert result == %{
             intro_statement:
               "Hi there,\n\nI have been developing software for 10 years. I have extensive\nexperience with many stacks, primarily Ruby On Rails and Phoenix. Today\nI like to write Ruby, Elixir, Go and ES6/React. I enjoy pair\nprogramming, reviewing code and giving constructive feedback.\n\nI\\'ve worked with large corporations, fast paced agencies, and lean\nstartups producing production grade code for highly distributed, data\nintensive applications.\n"
           }
  end

  test "it gets tools" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_tools({html, %{}})

    assert result == %{tools: "Favorite editor: vim + tmux • First computer: Macintosh"}
  end

  test "it gets user technologies" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_technologies({html, %{}})

    assert result == %{
             technologies: [
               "elixir",
               "ruby",
               "go",
               "python",
               "machine-learning",
               "ruby-on-rails",
               "phoenix",
               "nerves-project",
               "iot"
             ]
           }
  end

  test "it gets assessments" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_assessments({html, %{}})

    assert result == %{
             assessments: %{
               banner_logo: %{
                 img:
                   "https://cdn.sstatic.net/Img/developer-story/pluralsight/iq-logo.svg?v=771676feee19",
                 alt: "Pluralsight IQ"
               },
               items: [
                 %{
                   tag: "ruby",
                   img: "https://i.stack.imgur.com/xbQ6L.png",
                   alt: "Score: 244/300"
                 },
                 %{
                   tag: "ruby-on-rails",
                   img: "https://i.stack.imgur.com/qkNau.png",
                   alt: "Score: 211/300"
                 },
                 %{
                   tag: "elixir",
                   img: "https://i.stack.imgur.com/M68kU.png",
                   alt: "Score: 201/300"
                 }
               ]
             }
           }
  end

  test "it gets the timeline" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_timeline({html, %{}})

    assert List.first(result.timeline).location == "ConvertKit"
  end

  test "it gets reading" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.get_reading({html, %{}})

    assert List.first(result.reading).title == "The Ruby Programming Language"
  end

  defp load_file(relative_path) do
    (File.cwd!() <> relative_path)
    |> Path.expand(relative_path)
    |> Path.absname()
    |> File.read()
  end
end
