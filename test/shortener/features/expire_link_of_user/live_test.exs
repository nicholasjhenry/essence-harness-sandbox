defmodule Shortener.Features.ExpireLinkOfUser.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Shortener.Shared.{LinkExpirationSet, LinkShortened}

  defp shorten(short_code, owner) do
    fact = %LinkShortened{
      short_code: short_code,
      target_url: "https://example.com/" <> short_code,
      owner_email_address: owner,
      shortened_at: ~U[2026-10-24 21:26:00Z]
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

  defp submit(view, expires_at) do
    view
    |> form("#expire-link-form", command: %{expires_at: expires_at})
    |> render_submit()
  end

  describe "opening the page of the expiration" do
    test "redirects to the login page given a visitor", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/log-in"}}} = live(conn, ~p"/links/Abc1234/expiration")
    end

    test "shows the short URL and never given a link of the user", %{conn: conn} do
      shorten("Abc1234", "ada@example.com")

      {:ok, view, _html} =
        conn |> log_in_user("ada@example.com") |> live(~p"/links/Abc1234/expiration")

      assert view |> element("#expiration-short-url") |> render() =~
               ~r"http://localhost:\d+/Abc1234"

      assert view |> element("#expiration-current") |> render() =~ "Never"
      assert has_element?(view, ~s(#expire-link-form input[type="datetime-local"]))
    end

    test "goes to the list with an error given a link of a different user", %{conn: conn} do
      shorten("Grace12", "grace@example.com")

      assert {:error, {:live_redirect, %{to: "/links", flash: %{"error" => message}}}} =
               conn |> log_in_user("ada@example.com") |> live(~p"/links/Grace12/expiration")

      assert message == "You own no link with this short code."
    end

    test "goes to the list with an error given a link whose time of expiration is past",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      expire("Abc1234", "ada@example.com", ~U[2026-10-24 22:00:00Z])

      assert {:error, {:live_redirect, %{to: "/links", flash: %{"error" => message}}}} =
               conn |> log_in_user("ada@example.com") |> live(~p"/links/Abc1234/expiration")

      assert message == "The link has expired. Its time of expiration does not change."
    end
  end

  describe "setting the time of expiration on the page of the expiration" do
    setup %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      %{conn: log_in_user(conn, "ada@example.com")}
    end

    test "goes to the list with the time given a later time", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/links/Abc1234/expiration")

      {:ok, list, html} = view |> submit("2099-01-02T03:04") |> follow_redirect(conn, ~p"/links")

      assert html =~ "The link expires at 2099-01-02 03:04 UTC."
      assert list |> element("#expires-Abc1234") |> render() =~ "2099-01-02 03:04 UTC"
    end

    test "shows an error given an earlier time", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/links/Abc1234/expiration")

      assert submit(view, "2000-01-01T00:00") =~ "must be after the time now"
    end

    test "goes to the list with an error given an expiration that passed after the mount",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/links/Abc1234/expiration")
      expire("Abc1234", "ada@example.com", DateTime.add(DateTime.utc_now(), -1, :second))

      {:ok, _list, html} = view |> submit("2099-01-02T03:04") |> follow_redirect(conn, ~p"/links")

      assert html =~ "The link has expired. Its time of expiration does not change."
    end
  end
end
