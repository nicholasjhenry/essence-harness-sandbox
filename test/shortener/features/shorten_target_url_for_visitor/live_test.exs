defmodule Shortener.Features.ShortenTargetUrlForVisitor.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  describe "shortening a target URL on the page" do
    test "shows the short URL and the target URL given a valid submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#shorten-form", command: %{target_url: "https://example.com/a/long/path"})
      |> render_submit()

      assert has_element?(view, "#short-link-target", "https://example.com/a/long/path")
      assert view |> element("#short-url") |> render() =~ ~r"http://localhost:\d+/[A-Za-z0-9]{7}"
    end

    test "shows an error and no short URL given a URL with no scheme", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#shorten-form", command: %{target_url: "example.com"})
      |> render_submit()

      assert has_element?(view, "#shorten-form", "must be an http or https URL with a host")
      refute has_element?(view, "#short-link")
    end
  end
end
