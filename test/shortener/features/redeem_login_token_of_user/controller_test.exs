defmodule Shortener.Features.RedeemLoginTokenOfUser.ControllerTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Shortener.DCB.Query
  alias Shortener.Shared.{LoginLinkSent, Secret}
  alias ShortenerWeb.UserAuth

  defp send_login_link do
    token = Secret.generate()

    fact = %LoginLinkSent{
      email_address: "ada@example.com",
      token_hash: Secret.hash(token),
      sent_at: DateTime.utc_now()
    }

    :ok = Shortener.EventStore.append(LoginLinkSent.to_event(fact), nil)
    token
  end

  describe "the page of a login link" do
    test "shows the button, and redeems nothing", %{conn: conn} do
      token = send_login_link()

      {:ok, view, _html} = live(conn, ~p"/log-in/#{token}")

      assert has_element?(view, "#redeem-form button", "Log in")
      assert [%{event: %{type: "LoginLinkSent"}}] = Shortener.EventStore.read(Query.all(), [])
    end
  end

  describe "POST /log-in" do
    test "logs in the browser and redirects to the links of the user given a valid token", %{
      conn: conn
    } do
      token = send_login_link()

      conn = post(conn, ~p"/log-in", %{"login" => %{"token" => token}})

      assert redirected_to(conn) == ~p"/user-links"
      session_token = get_session(conn, UserAuth.session_key())

      assert UserAuth.scope_for_session_token(session_token).user.email_address ==
               "ada@example.com"

      assert get_session(conn, :live_socket_id) == "login_sessions:" <> Secret.hash(session_token)

      {:ok, _view, html} = conn |> recycle() |> get(~p"/user-links") |> then(&live(&1))
      assert html =~ "ada@example.com"
    end

    test "redirects to the login page with an error given a redeemed token", %{conn: conn} do
      token = send_login_link()
      post(conn, ~p"/log-in", %{"login" => %{"token" => token}})

      conn = post(build_conn(), ~p"/log-in", %{"login" => %{"token" => token}})

      assert redirected_to(conn) == ~p"/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "not valid"
      assert get_session(conn, UserAuth.session_key()) == nil
    end

    test "redirects to the login page given no token", %{conn: conn} do
      assert redirected_to(post(conn, ~p"/log-in", %{})) == ~p"/log-in"
    end
  end
end
