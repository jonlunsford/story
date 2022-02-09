defmodule Story.SOStoryScraperTest do
  use ExUnit.Case, async: true

  alias Story.SOStoryScraper

  test "it parses an entire document" do
    {:ok, html} = load_file("/test/support/stack_overflow_story.html")
    {_html, result} = SOStoryScraper.parse_full_document({html, %{}})

    assert Map.keys(result) == [
             :assessments,
             :intro_statement,
             :job,
             :links,
             :location,
             :name,
             :reading,
             :so,
             :technologies,
             :timeline,
             :tools
           ]
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
             links: [
               %{
                 href: "http://www.capturethecastle.net",
                 text: "http://www.capturethecastle.net"
               },
               %{href: "https://twitter.com/jonlunsford1", text: "jonlunsford1"},
               %{href: "https://github.com/jonlunsford", text: "jonlunsford"}
             ]
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
               "<p>Hi there,</p><p>I have been developing software for 10 years. I have extensive experience\nwith many stacks, primarily Ruby On Rails and Phoenix. Today I like to write Ruby, Elixir, Go and ES6/React. I enjoy pair programming, reviewing code and giving constructive feedback.</p><p>I&#39;ve worked with large corporations, fast paced agencies, and lean startups producing production grade code for highly distributed, data intensive applications.</p>"
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
