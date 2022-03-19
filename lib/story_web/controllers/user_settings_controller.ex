defmodule StoryWeb.UserSettingsController do
  use StoryWeb, :controller

  alias Story.Accounts
  alias Story.Pages
  alias StoryWeb.UserAuth

  plug :assign_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_slug"} = params) do
    user = conn.assigns.current_user
    %{"user" => user_params} = params

    case Accounts.apply_user_slug(user, user_params) do
      {:ok, _user} ->

        case Pages.get_user_latest_page_without_preloads(user) do
          nil -> :ok
          page ->
            Pages.update_page(page, %{slug: Map.get(user_params,"slug")})
        end

        conn
        |> put_flash(:info, "Vanity URL updated successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
      {:error, changeset} ->
        render(conn, "edit.html", slug_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  def destroy_user(conn, _params) do
    case Accounts.delete_user(conn.assigns.current_user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "You've. Done. It. Middle Earth has been saved! See ya!")
        |> UserAuth.log_out_user()
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "AHHH! The ring still exists!!")
        |> render("edit.html")
    end
  end

  defp assign_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
    |> assign(:slug_changeset, Accounts.change_user_slug(user))
  end
end
