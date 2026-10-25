defmodule Shortener.Features.ListLinksOfUser.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Shortener.Features.ResolveTargetUrlOfShortUrl
  alias Shortener.Shared.{LinkExpirationSet, LinkShortened}

  defp shorten(short_code, owner, shortened_at \\ ~U[2026-10-24 21:26:00Z]) do
    fact = %LinkShortened{
      short_code: short_code,
      target_url: "https://example.com/" <> short_code,
      owner_email_address: owner,
      shortened_at: shortened_at
    }

    :ok = Shortener.EventStore.append(LinkShortened.to_event(fact), nil)
  end

  defp expire(short_code, owner, expires_at) do
    fact = %LinkExpirationSet{
      short_code: short_code,
      owner_email_address: owner,
      expires_at: expires_at,
      set_at: DateTime.add(expires_at, -3600, :second)
    }

    :ok = Shortener.EventStore.append(LinkExpirationSet.to_event(fact), nil)
  end

  defp row_ids(html) do
    html
    |> LazyHTML.from_document()
    |> LazyHTML.query("#links tr")
    |> LazyHTML.attribute("id")
  end

  describe "listing the links of a user on the page of all the links" do
    test "redirects a visitor to the login page", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/log-in"}}} = live(conn, ~p"/links")
    end

    test "shows the short URL, the target URL, and the time of shortening given a link",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      row = view |> element("#link-Abc1234") |> render()
      assert row =~ ~r"http://localhost:\d+/Abc1234\s*<"
      assert row =~ "https://example.com/Abc1234"
      assert row =~ "2026-10-24 21:26 UTC"
      refute has_element?(view, "#no-links")
    end

    test "shows the newest link first given two links", %{conn: conn} do
      shorten("Older12", "ada@example.com", ~U[2026-10-24 10:00:00Z])
      shorten("Newer34", "ada@example.com", ~U[2026-10-24 11:00:00Z])

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert view |> render() |> row_ids() == [
               "link-Newer34",
               "link-Older12"
             ]
    end

    test "hides the links of a different user and of a visitor given three owners",
         %{conn: conn} do
      shorten("Ada1234", "ada@example.com")
      shorten("Grace12", "grace@example.com")
      shorten("Visit12", nil)

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert has_element?(view, "#link-Ada1234")
      refute has_element?(view, "#link-Grace12")
      refute has_element?(view, "#link-Visit12")
    end

    test "shows the message with a link to the shortening page given no link", %{conn: conn} do
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert has_element?(view, "#no-links", "You own no links.")
      assert has_element?(view, ~s|#no-links a[href="/user-links"]|)
      refute has_element?(view, "#links")
    end

    test "shows the link that the user shortened on the page of the links of a user",
         %{conn: conn} do
      conn = log_in_user(conn, "ada@example.com")
      {:ok, shorten_view, _html} = live(conn, ~p"/user-links")

      shorten_view
      |> form("#shorten-for-user-form",
        command: %{target_url: "https://example.com/path", short_code: "Summer1"}
      )
      |> render_submit()

      {:ok, view, _html} = live(conn, ~p"/links")

      assert view |> element("#link-Summer1") |> render() =~ "https://example.com/path"
    end

    test "opens each short URL in a new browser tab given a link", %{conn: conn} do
      shorten("Abc1234", "ada@example.com")

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert has_element?(
               view,
               ~s|#link-Abc1234 a[href$="/Abc1234"][target="_blank"][rel="noopener noreferrer"]|
             )
    end

    test "shows the menu item of the page to a logged-in user", %{conn: conn} do
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/user-links")

      assert has_element?(view, ~s|a[href="/links"]|, "All your links")
    end
  end

  describe "offering the deletion of a link on the page of all the links" do
    test "shows a delete action that asks for a confirmation given a link", %{conn: conn} do
      shorten("Abc1234", "ada@example.com")

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert has_element?(
               view,
               ~s|#delete-Abc1234[href="/links/Abc1234"][data-method="delete"][data-confirm]|
             )
    end
  end

  describe "showing the resolutions of each link on the page of all the links" do
    test "shows the count of each link given a link with two resolutions and a link with none",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      shorten("Xyz9876", "ada@example.com")
      now = DateTime.utc_now()
      {:ok, _resolved} = ResolveTargetUrlOfShortUrl.CommandHandler.handle("Abc1234", now)
      {:ok, _resolved} = ResolveTargetUrlOfShortUrl.CommandHandler.handle("Abc1234", now)

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert has_element?(view, "th", "Resolutions")
      assert view |> element("#resolutions-Abc1234") |> render() =~ ">2<"
      assert view |> element("#resolutions-Xyz9876") |> render() =~ ">0<"
    end

    test "counts the resolution of the short URL given a request for the short URL",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      conn = log_in_user(conn, "ada@example.com")

      get(conn, "/Abc1234")
      {:ok, view, _html} = live(conn, ~p"/links")

      assert view |> element("#resolutions-Abc1234") |> render() =~ ">1<"
    end
  end

  describe "updating the resolutions of each link on the open page of all the links" do
    test "shows the new count with no reload given a resolution of a link of the user",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      {:ok, _resolved} =
        ResolveTargetUrlOfShortUrl.CommandHandler.handle("Abc1234", DateTime.utc_now())

      assert view |> element("#resolutions-Abc1234") |> render() =~ ">1<"
    end
  end

  describe "showing the time of expiration of each link on the page of all the links" do
    test "shows never and offers the expiration given a link with no expiration", %{conn: conn} do
      shorten("Abc1234", "ada@example.com")

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert has_element?(view, "th", "Expires")
      assert view |> element("#expires-Abc1234") |> render() =~ "Never"

      assert view |> element("#expire-Abc1234") |> render() =~
               ~s(href="/links/Abc1234/expiration")

      assert view |> element("#expire-Abc1234") |> render() =~ "Expire"
    end

    test "shows the time and offers the expiration given a later time of expiration",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      expire("Abc1234", "ada@example.com", ~U[2099-01-02 03:04:00Z])

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert view |> element("#expires-Abc1234") |> render() =~ "2099-01-02 03:04 UTC"
      refute view |> element("#expires-Abc1234") |> render() =~ "Expired"
      assert view |> element("#expire-Abc1234") |> render() =~ "Change expiration"
    end

    test "shows expired and does not offer the expiration given a time of expiration that is past",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      expire("Abc1234", "ada@example.com", ~U[2026-10-24 22:00:00Z])

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert view |> element("#expires-Abc1234") |> render() =~ "Expired 2026-10-24 22:00 UTC"
      refute has_element?(view, "#expire-Abc1234")
      assert has_element?(view, "#delete-Abc1234")
    end
  end

  describe "offering the target URL change of a link on the page of all the links" do
    test "offers the target URL change given a link whose time of expiration is not past",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      assert view |> element("#change-target-url-Abc1234") |> render() =~
               ~s(href="/links/Abc1234/target-url")

      assert view |> element("#change-target-url-Abc1234") |> render() =~ "Change target URL"
    end

    test "does not offer the target URL change given a time of expiration that is past",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      expire("Abc1234", "ada@example.com", ~U[2026-10-24 22:00:00Z])

      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/links")

      refute has_element?(view, "#change-target-url-Abc1234")
    end
  end
end
