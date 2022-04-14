defmodule StoryWeb.PageView do
  use StoryWeb, :view

  alias Phoenix.LiveView.JS
  alias Story.Timelines.Item
  alias Story.Tags.Tag

  import StoryWeb.LayoutView, only: [underscore_string: 1, dasherize_string: 1, markdown_as_html: 1]
  import StoryWeb.TimelineView, only: [order_timeline: 1, group_timeline_for_csv: 1, timeline_span: 1]

  def toggle_cv_item_text_on(title) do
    "Show More #{String.trim(title)}"
  end

  def toggle_cv_item_text_off(title) do
    "Show Less #{String.trim(title)}"
  end

  def dummy_timeline do
    {:ok, ruby_date} = NaiveDateTime.new(2021,07,1,0,0,0)
    {:ok, elixri_date} = NaiveDateTime.new(2021,12,1,0,0,0)

    [
      %Item{
        type: "position",
        start_date: Timex.shift(NaiveDateTime.utc_now(), years: -5),
        current_position: true,
        url: "https://devstory.fyi",
        title: "Engineer",
        location: "Acme Corp.",
        img: "/images/logoipsum-logo-39.svg",
        description: "I'm a Software Engineer at Acme Corp. I'm working on next gen Acme things, doing awesome stuff!",
        tags: [
          %Tag{name: "ruby"},
          %Tag{name: "ruby-on-rails"},
          %Tag{name: "aws"},
          %Tag{name: "react"},
          %Tag{name: "go"},
          %Tag{name: "python"},
          %Tag{name: "machine-learning"}
        ]
      },
      %Item{
        type: "blogs_or_videos",
        start_date: Timex.shift(NaiveDateTime.utc_now(), months: -2),
        url: "https://devstory.fyi",
        title: "I like to write. This is a blog post.",
        img: "https://placedog.net/350/196",
        location: "Acme Corp.",
        description: "Even though I'm currently employed, I'm still doing things like writing blog posts about cool stuff I'm learning or working on. Check this one out!",
        tags: [
          %Tag{name: "dev-ops"},
          %Tag{name: "mysql"},
          %Tag{name: "redis"},
          %Tag{name: "sidekiq"}
        ]
      },
      %Item{
        type: "open_source",
        start_date: Timex.shift(NaiveDateTime.utc_now(), years: -2),
        end_date: Timex.shift(NaiveDateTime.utc_now(), years: -1),
        title: "The Blockchain",
        url: "https://github.com/",
        description: "For about a year, I maintained this pretty successful open-source project. Then I made some foolish bets.",
        tags: [
          %Tag{name: "blockchain"}
        ]
      },
      %Item{
        type: "assessment",
        start_date: elixri_date,
        title: "Elixir - Score: 201/300",
        img: "https://i.stack.imgur.com/FpJtT.png",
        tags: [
          %Tag{name: "elixir"}
        ]
      },
      %Item{
        type: "assessment",
        start_date: ruby_date,
        title: "Ruby Language Fundamentals - Score: 244/300",
        img: "https://i.stack.imgur.com/DhhDh.png",
        tags: [
          %Tag{name: "ruby"}
        ]
      },
      %Item{
        type: "position",
        start_date: Timex.shift(NaiveDateTime.utc_now(), years: -9),
        end_date: Timex.shift(NaiveDateTime.utc_now(), years: -7),
        url: "https://devstory.fyi",
        title: "Jr. Engineer",
        location: "Big Corp.",
        img: "/images/logoipsum-logo-37.svg",
        description: "I was a Jr. Engineer at Big Corp. I was working on next gen Big things, doing awesome stuff!",
        tags: [
          %Tag{name: "javascript"},
          %Tag{name: "es6"},
          %Tag{name: "jest"},
          %Tag{name: "typescript"},
          %Tag{name: "vue"},
          %Tag{name: "react"},
          %Tag{name: "elm"}
        ]
      },
      %Item{
        type: "education",
        start_date: Timex.shift(NaiveDateTime.utc_now(), years: -20),
        end_date: Timex.shift(NaiveDateTime.utc_now(), years: -16),
        title: "BS in computer science",
        location: "UC Fancy Pants",
        img: "/images/logoipsum-logo-31.svg",
        description: "I could have saved a lot of time and money if I had known that all the answers were on StackOverflow. ",
        tags: [
          %Tag{name: "CS-101"},
          %Tag{name: "java"},
          %Tag{name: "C++"}
        ]
      }
    ]
  end
end
