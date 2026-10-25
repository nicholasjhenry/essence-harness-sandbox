defmodule Shortener.Features.ShortenTargetUrlForVisitor.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Shortener.Features.ShortenTargetUrlForVisitor.{Command, CommandHandler}

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

    test "redirects the short URL to the target URL given a chosen short code", %{conn: conn} do
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

  describe "counting the characters of the short code on the page" do
    test "shows 0/7 given no short code in the field", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#short-code-count", "0/7")
    end

    test "shows the number of characters given a change of the field", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      change(view, "abc")
      assert has_element?(view, "#short-code-count", "3/7")

      change(view, "Summer1")
      assert has_element?(view, "#short-code-count", "7/7")
    end

    test "counts each space given a short code with a space at the end", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      change(view, "abc ")

      assert has_element?(view, "#short-code-count", "4/7")
    end

    test "limits the field to seven characters with no debounce", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#command_short_code[maxlength='7']")
      refute has_element?(view, "#command_short_code[phx-debounce]")
    end

    test "shows 0/7 given a link made with a chosen short code", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      change(view, "Summer1")
      submit(view, %{target_url: @url, short_code: "Summer1"})

      assert has_element?(view, "#short-link")
      assert has_element?(view, "#short-code-count", "0/7")
    end

    test "shows 3/7 and the form error given a submission of three characters", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      submit(view, %{target_url: @url, short_code: "abc"})

      assert has_element?(view, "#short-code-count", "3/7")

      assert has_element?(
               view,
               "#shorten-form",
               "must be seven characters from A–Z, a–z, and 0–9"
             )
    end
  end

  describe "checking the availability of the short code on the page" do
    test "shows no availability given the page on mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert availability(view) == ""
    end

    test "shows that no link has the short code given a change of the field to a free short code",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      change(view, "Summer1")

      assert availability(view) == "No link has this short code."
    end

    test "shows that a link has the short code given a change of the field to the short code of a link",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      submit(view, %{target_url: @url, short_code: "Summer1"})

      change(view, "Summer1")

      assert availability(view) == "A link has this short code. Choose a different short code."
    end

    test "shows the availability of the short code without its spaces given a change of the field with spaces",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      submit(view, %{target_url: @url, short_code: "Summer1"})

      change(view, " Summer1 ")

      assert availability(view) == "A link has this short code. Choose a different short code."
    end

    test "shows no availability given a change of the field to a value of three characters",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      change(view, "abc")

      assert availability(view) == ""
    end

    test "shows the error on the field given a submission of a short code that a link took after the check",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      change(view, "Summer1")
      assert availability(view) == "No link has this short code."

      {:ok, _link} =
        %Command{}
        |> Command.changeset(%{"target_url" => @url, "short_code" => "Summer1"})
        |> Ecto.Changeset.apply_action!(:insert)
        |> CommandHandler.handle(["Summer1"], DateTime.utc_now())

      submit(view, %{target_url: @url, short_code: "Summer1"})

      assert has_element?(
               view,
               "#shorten-form",
               "is the short code of a link. Choose a different short code"
             )

      refute has_element?(view, "#short-link")
      assert availability(view) == ""
    end

    test "shows no availability given a new link with a chosen short code", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      change(view, "Summer1")

      submit(view, %{target_url: @url, short_code: "Summer1"})

      assert has_element?(view, "#short-link")
      assert availability(view) == ""
    end

    test "keeps the availability given a submission with a target URL that has no scheme",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      change(view, "Summer1")

      submit(view, %{target_url: "example.com", short_code: "Summer1"})

      assert has_element?(view, "#shorten-form", "must be an http or https URL with a host")
      assert availability(view) == "No link has this short code."
    end
  end

  defp availability(view) do
    view
    |> element("#short-code-availability")
    |> render()
    |> String.replace(~r/<[^>]*>/, "")
    |> String.trim()
  end

  defp change(view, short_code) do
    view
    |> form("#shorten-form", command: %{short_code: short_code})
    |> render_change()
  end
end
