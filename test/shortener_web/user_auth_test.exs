defmodule ShortenerWeb.UserAuthTest do
  use ShortenerWeb.ConnCase, async: false

  alias Shortener.Shared.{Scope, Secret, User}
  alias ShortenerWeb.UserAuth

  describe "the scope of a session token" do
    test "gives the user of the login session" do
      session_token = Shortener.LoginFixtures.start_login_session("ada@example.com")

      assert %Scope{
               user: %User{email_address: "ada@example.com"},
               session_token_hash: hash
             } = UserAuth.scope_for_session_token(session_token)

      assert hash == Secret.hash(session_token)
    end

    test "gives nil given no session token, or a session token of no login session" do
      assert UserAuth.scope_for_session_token(nil) == nil
      assert UserAuth.scope_for_session_token(Secret.generate()) == nil
    end
  end

  describe "the layout" do
    test "shows the login link to a visitor", %{conn: conn} do
      html = conn |> get(~p"/") |> html_response(200)

      assert html =~ ~s(id="log-in")
      refute html =~ ~s(id="log-out")
    end

    test "shows the email address and the logout link to a user", %{conn: conn} do
      html = conn |> log_in_user("ada@example.com") |> get(~p"/") |> html_response(200)

      assert html =~ "ada@example.com"
      assert html =~ ~s(id="log-out")
    end
  end
end
