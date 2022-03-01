defmodule Story.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Story.Accounts` context.
  """

  def time_stamp do
    {:ok, time} = DateTime.now("Etc/UTC")
    DateTime.to_unix(time)
  end
  def unique_user_email, do: "user#{System.unique_integer()}-#{time_stamp()}@example.com"
  def unique_slug, do: "user#{System.unique_integer()}-my-#{time_stamp()}-slug"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      slug: unique_slug(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Story.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
