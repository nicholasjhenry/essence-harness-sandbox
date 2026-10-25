defmodule Shortener.Features.ShortenTargetUrlForUser.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Shortener.LoginFixtures

  alias Shortener.Features.ShortenTargetUrlForUser.{Command, CommandHandler}

  defp shorten_links(email_address, count) do
    command =
      %Command{}
      |> Command.changeset(%{"target_url" => "https://example.com"})
      |> Ecto.Changeset.apply_action!(:insert)

    scope = login_scope(email_address)

    for n <- 1..count,
        do:
          {:ok, _} = CommandHandler.handle(scope, command, ["code#{100 + n}"], DateTime.utc_now())
  end

  defp submit(view) do
    view
    |> form("#shorten-for-user-form", command: %{target_url: "https://example.com/path"})
    |> render_submit()
  end

  describe "shortening a target URL on the page of the links of a user" do
    test "redirects a visitor to the login page", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/log-in"}}} = live(conn, ~p"/user-links")
    end

    test "shows the link usage of the logged-in user on mount", %{conn: conn} do
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/user-links")

      assert has_element?(view, "#link-usage-count", "0 of 10 links")
      refute has_element?(view, "#shorten-for-user-form input[name='command[email_address]']")
    end

    test "shows the short URL and the link usage given a valid submission", %{conn: conn} do
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/user-links")

      submit(view)

      assert has_element?(view, "#short-url")
      assert has_element?(view, "#link-usage-count", "1 of 10 links")
      assert has_element?(view, "#link-usage-plan", "Free")
    end

    test "shows the link limit error given a user at the link limit", %{conn: conn} do
      shorten_links("ada@example.com", 10)
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/user-links")

      submit(view)

      assert has_element?(
               view,
               "#shorten-for-user-form",
               "you have reached the link limit of your plan"
             )

      assert has_element?(view, "#link-usage-count", "10 of 10 links")
      refute has_element?(view, "#short-url")
    end
  end

  describe "choosing the short code on the page of the links of a user" do
    test "shows the short URL of the chosen short code and counts the link given a free short code",
         %{conn: conn} do
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/user-links")

      view
      |> form("#shorten-for-user-form",
        command: %{target_url: "https://example.com/path", short_code: "Summer1"}
      )
      |> render_submit()

      assert view |> element("#short-url") |> render() =~ ~r"http://localhost:\d+/Summer1<"
      assert has_element?(view, "#link-usage-count", "1 of 10 links")
    end

    test "shows the error on the field and keeps the link usage given a short code that a link has",
         %{conn: conn} do
      shorten_links("grace@example.com", 1)
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/user-links")

      view
      |> form("#shorten-for-user-form",
        command: %{target_url: "https://example.com/path", short_code: "code101"}
      )
      |> render_submit()

      assert has_element?(
               view,
               "#shorten-for-user-form",
               "is the short code of a link. Choose a different short code"
             )

      assert has_element?(view, "#link-usage-count", "0 of 10 links")
      refute has_element?(view, "#short-url")
    end
  end

  describe "counting the characters of the short code on the page of the links of a user" do
    test "shows the number of characters with a limit of seven given a change of the field",
         %{conn: conn} do
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/user-links")

      assert has_element?(view, "#short-code-count", "0/7")
      assert has_element?(view, "#command_short_code[maxlength='7']")

      view
      |> form("#shorten-for-user-form", command: %{short_code: "abc"})
      |> render_change()

      assert has_element?(view, "#short-code-count", "3/7")
    end
  end
end
