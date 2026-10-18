defmodule Shortener.Features.ShortenTargetUrlForUser.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Shortener.Features.ShortenTargetUrlForUser.{Command, CommandHandler}

  defp shorten_links(email_address, count) do
    command =
      %Command{}
      |> Command.changeset(%{
        "email_address" => email_address,
        "target_url" => "https://example.com"
      })
      |> Ecto.Changeset.apply_action!(:insert)

    for n <- 1..count,
        do: {:ok, _} = CommandHandler.handle(command, ["code#{100 + n}"], DateTime.utc_now())
  end

  defp submit(view, email_address) do
    view
    |> form("#shorten-for-user-form",
      command: %{email_address: email_address, target_url: "https://example.com/path"}
    )
    |> render_submit()
  end

  describe "shortening a target URL for a user on the page" do
    test "shows the short URL and the link usage given a valid submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/user-links")

      submit(view, "ada@example.com")

      assert has_element?(view, "#short-url")
      assert has_element?(view, "#link-usage-count", "1 of 10 links")
      assert has_element?(view, "#link-usage-plan", "Free")
    end

    test "shows the link limit error given a user at the link limit", %{conn: conn} do
      shorten_links("ada@example.com", 10)
      {:ok, view, _html} = live(conn, ~p"/user-links")

      submit(view, "ada@example.com")

      assert has_element?(
               view,
               "#shorten-for-user-form",
               "the user has reached the link limit of the plan"
             )

      assert has_element?(view, "#link-usage-count", "10 of 10 links")
      refute has_element?(view, "#short-url")
    end

    test "shows an error given an email address with no domain", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/user-links")

      submit(view, "ada")

      assert has_element?(view, "#shorten-for-user-form", "must have the form name@domain")
    end
  end
end
