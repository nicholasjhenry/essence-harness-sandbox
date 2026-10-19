defmodule Shortener.Features.SendLoginLinkToUser.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import ExUnit.CaptureLog

  require Logger
  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  describe "asking for a login link on the page" do
    test "sends an email with the login link given a valid email address", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/log-in")

      view
      |> form("#login-form", command: %{email_address: "ada@example.com"})
      |> render_submit()

      assert has_element?(view, "#login-link-sent", "ada@example.com")

      assert_email_sent(fn email ->
        assert email.to == [{"", "ada@example.com"}]
        assert email.text_body =~ ~r"http://localhost:\d+/log-in/[A-Za-z0-9_-]{43}"
      end)
    end

    test "logs the login link given the setting of development", %{conn: conn} do
      Application.put_env(:shortener, :log_login_links, true)
      level = Logger.level()
      Logger.configure(level: :info)

      on_exit(fn ->
        Application.delete_env(:shortener, :log_login_links)
        Logger.configure(level: level)
      end)

      {:ok, view, _html} = live(conn, ~p"/log-in")

      log =
        capture_log([level: :info], fn ->
          view
          |> form("#login-form", command: %{email_address: "ada@example.com"})
          |> render_submit()
        end)

      assert log =~
               ~r"Login link for ada@example.com: http://localhost:\d+/log-in/[A-Za-z0-9_-]{43}"
    end

    test "logs no login link given no setting", %{conn: conn} do
      level = Logger.level()
      Logger.configure(level: :info)
      on_exit(fn -> Logger.configure(level: level) end)

      {:ok, view, _html} = live(conn, ~p"/log-in")

      log =
        capture_log([level: :info], fn ->
          view
          |> form("#login-form", command: %{email_address: "ada@example.com"})
          |> render_submit()
        end)

      refute log =~ "Login link"
    end

    test "shows an error and sends no email given an email address with no domain", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/log-in")

      view |> form("#login-form", command: %{email_address: "ada"}) |> render_submit()

      assert has_element?(view, "#login-form", "must have the form name@domain")
      refute has_element?(view, "#login-link-sent")
      assert_no_email_sent()
    end
  end
end
