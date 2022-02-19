defmodule StoryWeb.OAuthController do
  @moduledoc """
  OAuth controller responsible for handling Ueberauth responses
  """

  use StoryWeb, :controller

  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias Story.Accounts
  alias StoryWeb.UserAuth

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    UserAuth.log_out_user(conn)
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.register_user_from_auth(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> UserAuth.log_in_user(user)

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
