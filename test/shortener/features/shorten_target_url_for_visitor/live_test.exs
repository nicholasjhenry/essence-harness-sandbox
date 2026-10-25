defmodule Shortener.Features.ShortenTargetUrlForVisitor.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  @url "https://example.com/a/long/path"

  defp submit(view, command) do
    view
    |> form("#shorten-form", command: command)
    |> render_submit()
  end

  describe "shortening a target URL on the page" do
    test "shows the short URL and the target URL given a valid submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      submit(view, %{target_url: @url})

      assert has_element?(view, "#short-link-target", @url)
      assert view |> element("#short-url") |> render() =~ ~r"http://localhost:\d+/[A-Za-z0-9]{7}"
    end

    test "shows an error and no short URL given a URL with no scheme", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      submit(view, %{target_url: "example.com"})

      assert has_element?(view, "#shorten-form", "must be an http or https URL with a host")
      refute has_element?(view, "#short-link")
    end
  end

  describe "choosing the short code on the page" do
    test "shows the short URL of the chosen short code given a free short code", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      submit(view, %{target_url: @url, short_code: " Summer1 "})

      assert view |> element("#short-url") |> render() =~ ~r"http://localhost:\d+/Summer1<"
    end

    test "resolves the short URL of the chosen short code to the target URL", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      submit(view, %{target_url: @url, short_code: "Summer1"})

      conn = get(conn, "/Summer1")

      assert conn.status == 302
      assert get_resp_header(conn, "location") == [@url]
    end

    test "shows the error on the field and no short URL given a short code that a link has",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      submit(view, %{target_url: @url, short_code: "Summer1"})

      submit(view, %{target_url: "https://example.com/other", short_code: "Summer1"})

      assert has_element?(
               view,
               "#shorten-form",
               "is the short code of a link. Choose a different short code"
             )

      refute has_element?(view, "#short-link")
    end

    test "shows the short URL given a short code that differs only in case from a link",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      submit(view, %{target_url: @url, short_code: "Summer1"})

      submit(view, %{target_url: @url, short_code: "summer1"})

      assert view |> element("#short-url") |> render() =~ ~r"http://localhost:\d+/summer1<"
    end

    test "shows the form error and no short URL given a short code of three characters",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      submit(view, %{target_url: @url, short_code: "abc"})

      assert has_element?(
               view,
               "#shorten-form",
               "must be seven characters from A–Z, a–z, and 0–9"
             )

      refute has_element?(view, "#short-link")
    end

    test "shows a short URL of seven characters given an empty short code", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      submit(view, %{target_url: @url, short_code: ""})

      assert view |> element("#short-url") |> render() =~ ~r"http://localhost:\d+/[A-Za-z0-9]{7}<"
    end
  end
end
