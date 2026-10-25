defmodule Shortener.Features.ChangeTargetUrlOfLink.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Shortener.LoginFixtures

  alias Shortener.Features.EndLoginSessionOfUser
  alias Shortener.Shared.{LinkExpirationSet, LinkShortened, LinkTargetUrlChanged}

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

  defp change(short_code, owner, target_url) do
    fact = %LinkTargetUrlChanged{
      short_code: short_code,
      owner_email_address: owner,
      target_url: target_url,
      changed_at: DateTime.utc_now()
    }

    :ok = Shortener.EventStore.append(LinkTargetUrlChanged.to_event(fact), nil)
  end

  defp submit(view, target_url) do
    view
    |> form("#change-target-url-form", command: %{target_url: target_url})
    |> render_submit()
  end

  describe "opening the page of the target URL change" do
    test "redirects to the login page given a visitor", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/log-in"}}} = live(conn, ~p"/links/Abc1234/target-url")
    end

    test "shows the short URL and the target URL given a link of the user", %{conn: conn} do
      shorten("Abc1234", "ada@example.com")

      {:ok, view, html} =
        conn |> log_in_user("ada@example.com") |> live(~p"/links/Abc1234/target-url")

      assert html =~ "Change a target URL"
      assert html =~ "The short URL stays the same, and goes to the new target URL."
      assert page_title(view) =~ "Change a target URL"

      assert view |> element("#change-target-url-short-url") |> render() =~
               ~r"http://localhost:\d+/Abc1234"

      assert view |> element("#change-target-url-current") |> render() =~
               "https://example.com/Abc1234"

      assert has_element?(
               view,
               ~s(#change-target-url-form input[type="url"][value="https://example.com/Abc1234"])
             )
    end

    test "goes to the list with an error given a link of a different user", %{conn: conn} do
      shorten("Grace12", "grace@example.com")

      assert {:error, {:live_redirect, %{to: "/links", flash: %{"error" => message}}}} =
               conn |> log_in_user("ada@example.com") |> live(~p"/links/Grace12/target-url")

      assert message == "You own no link with this short code."
    end

    test "goes to the list with an error given a link whose time of expiration is past",
         %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      expire("Abc1234", "ada@example.com", ~U[2026-10-24 22:00:00Z])

      assert {:error, {:live_redirect, %{to: "/links", flash: %{"error" => message}}}} =
               conn |> log_in_user("ada@example.com") |> live(~p"/links/Abc1234/target-url")

      assert message == "The link has expired. Its target URL does not change."
    end
  end

  describe "changing the target URL on the page of the target URL change" do
    setup %{conn: conn} do
      shorten("Abc1234", "ada@example.com")
      session_token = start_login_session("ada@example.com")
      session = %{ShortenerWeb.UserAuth.session_key() => session_token}
      %{conn: init_test_session(conn, session), session_token: session_token}
    end

    test "goes to the list with the new target URL given a new target URL", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/links/Abc1234/target-url")

      {:ok, list, html} =
        view |> submit("https://example.com/new") |> follow_redirect(conn, ~p"/links")

      assert html =~ "The short URL now goes to https://example.com/new."
      assert list |> element("#link-Abc1234") |> render() =~ "https://example.com/new"
    end

    test "shows an error given the target URL of the link", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/links/Abc1234/target-url")

      assert submit(view, "https://example.com/Abc1234") =~
               "must differ from the target URL of the link"
    end

    test "shows an error given a URL with the ftp scheme", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/links/Abc1234/target-url")

      assert submit(view, "ftp://example.com") =~ "must be an http or https URL with a host"
    end

    test "shows an error given a change to the same target URL after the mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/links/Abc1234/target-url")
      change("Abc1234", "ada@example.com", "https://example.com/new")

      assert submit(view, "https://example.com/new") =~
               "must differ from the target URL of the link"
    end

    test "goes to the login page given a logout after the mount",
         %{conn: conn, session_token: session_token} do
      {:ok, view, _html} = live(conn, ~p"/links/Abc1234/target-url")
      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, DateTime.utc_now())

      assert {:error, {:redirect, %{to: "/log-in"}}} = submit(view, "https://example.com/new")
      assert {"/log-in", %{"error" => message}} = assert_redirect(view)
      assert message == "Log in to change a target URL."
    end
  end
end
