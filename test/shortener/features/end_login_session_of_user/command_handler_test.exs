defmodule Shortener.Features.EndLoginSessionOfUser.CommandHandlerTest do
  use Shortener.DataCase, async: false

  alias Shortener.DCB.Query
  alias Shortener.Features.EndLoginSessionOfUser.CommandHandler
  alias Shortener.Projections.LoginSessionUser
  alias Shortener.Shared.Secret

  describe "ending a login session" do
    test "makes the session token identify no user" do
      session_token = Shortener.LoginFixtures.start_login_session("ada@example.com")

      assert :ok = CommandHandler.handle(session_token, DateTime.utc_now())
      assert LoginSessionUser.of(Secret.hash(session_token)) == nil
    end

    test "appends nothing given a session token of no login session" do
      assert :ok = CommandHandler.handle(Secret.generate(), DateTime.utc_now())
      assert Shortener.EventStore.read(Query.all(), []) == []
    end
  end
end
