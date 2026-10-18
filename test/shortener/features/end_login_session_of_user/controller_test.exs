defmodule Shortener.Features.EndLoginSessionOfUser.ControllerTest do
  use ShortenerWeb.ConnCase, async: false

  alias ShortenerWeb.UserAuth

  describe "DELETE /log-out" do
    test "clears the session and redirects to the visitor page", %{conn: conn} do
      conn = log_in_user(conn, "ada@example.com")
      session_token = get_session(conn, UserAuth.session_key())

      conn = delete(conn, ~p"/log-out")

      assert redirected_to(conn) == ~p"/"
      assert get_session(conn, UserAuth.session_key()) == nil
      assert UserAuth.scope_for_session_token(session_token) == nil
    end

    test "redirects to the login page given the old session token after the logout", %{conn: conn} do
      conn = log_in_user(conn, "ada@example.com")
      session_token = get_session(conn, UserAuth.session_key())
      delete(conn, ~p"/log-out")

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{UserAuth.session_key() => session_token})
        |> get(~p"/plans")

      assert redirected_to(conn) == ~p"/log-in"
    end

    test "redirects to the visitor page given no login session", %{conn: conn} do
      assert redirected_to(delete(conn, ~p"/log-out")) == ~p"/"
    end
  end
end
