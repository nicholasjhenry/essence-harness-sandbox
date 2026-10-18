defmodule Shortener.Features.SendLoginLinkToUser.LiveTest do
  use ShortenerWeb.ConnCase, async: false

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

    test "shows an error and sends no email given an email address with no domain", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/log-in")

      view |> form("#login-form", command: %{email_address: "ada"}) |> render_submit()

      assert has_element?(view, "#login-form", "must have the form name@domain")
      refute has_element?(view, "#login-link-sent")
      assert_no_email_sent()
    end
  end
end
