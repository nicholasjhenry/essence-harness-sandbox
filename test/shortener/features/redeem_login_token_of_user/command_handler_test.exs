defmodule Shortener.Features.RedeemLoginTokenOfUser.CommandHandlerTest do
  use Shortener.DataCase, async: false

  alias Shortener.DCB.DecisionModel
  alias Shortener.EventStore
  alias Shortener.Features.RedeemLoginTokenOfUser.{CommandHandler, LoginTokenStatus}
  alias Shortener.Projections.LoginSessionUser
  alias Shortener.Shared.{LoginLinkSent, LoginTokenRedeemed, Secret}

  @sent_at ~U[2026-10-17 12:00:00.000000Z]

  defp send_login_link(email_address \\ "ada@example.com") do
    token = Secret.generate()

    fact = %LoginLinkSent{
      email_address: email_address,
      token_hash: Secret.hash(token),
      sent_at: @sent_at
    }

    :ok = EventStore.append(LoginLinkSent.to_event(fact), nil)
    token
  end

  defp later(seconds), do: DateTime.add(@sent_at, seconds, :second)

  describe "redeeming a login token" do
    test "starts a login session for the user of the login token" do
      token = send_login_link()
      session_token = Secret.generate()

      assert {:ok, "ada@example.com"} = CommandHandler.handle(token, session_token, later(60))
      assert LoginSessionUser.of(Secret.hash(session_token)) == "ada@example.com"
    end

    test "returns invalid token given the login token is redeemed" do
      token = send_login_link()
      {:ok, _} = CommandHandler.handle(token, Secret.generate(), later(60))

      second_session_token = Secret.generate()

      assert {:error, :invalid_token} =
               CommandHandler.handle(token, second_session_token, later(61))

      assert LoginSessionUser.of(Secret.hash(second_session_token)) == nil
    end

    test "returns invalid token given a login token that was never sent" do
      assert {:error, :invalid_token} =
               CommandHandler.handle(Secret.generate(), Secret.generate(), later(60))
    end

    test "redeems a login token at 14 minutes and at exactly 15 minutes" do
      assert {:ok, _} =
               CommandHandler.handle(send_login_link(), Secret.generate(), later(14 * 60))

      assert {:ok, _} =
               CommandHandler.handle(send_login_link(), Secret.generate(), later(15 * 60))
    end

    test "returns invalid token given a login token at 15 minutes and one second" do
      assert {:error, :invalid_token} =
               CommandHandler.handle(send_login_link(), Secret.generate(), later(15 * 60 + 1))
    end

    test "returns invalid token given a login token at 15 minutes and one microsecond" do
      now = @sent_at |> DateTime.add(15 * 60, :second) |> DateTime.add(1, :microsecond)

      assert {:error, :invalid_token} =
               CommandHandler.handle(send_login_link(), Secret.generate(), now)
    end

    test "fails the append given a redemption of the same login token after the read" do
      token = send_login_link()
      token_hash = Secret.hash(token)

      {_model, condition} =
        DecisionModel.build(EventStore, login_token: LoginTokenStatus.new(token_hash))

      {:ok, _} = CommandHandler.handle(token, Secret.generate(), later(60))

      event =
        LoginTokenRedeemed.to_event(%LoginTokenRedeemed{
          email_address: "ada@example.com",
          token_hash: token_hash,
          session_token_hash: Secret.hash(Secret.generate()),
          redeemed_at: later(61)
        })

      assert {:error, :append_condition_failed} = EventStore.append(event, condition)
    end

    test "appends given a redemption of a different login token after the read" do
      token_hash = Secret.hash(send_login_link())

      {_model, condition} =
        DecisionModel.build(EventStore, login_token: LoginTokenStatus.new(token_hash))

      {:ok, _} = CommandHandler.handle(send_login_link(), Secret.generate(), later(60))

      event =
        LoginTokenRedeemed.to_event(%LoginTokenRedeemed{
          email_address: "ada@example.com",
          token_hash: token_hash,
          session_token_hash: Secret.hash(Secret.generate()),
          redeemed_at: later(61)
        })

      assert :ok = EventStore.append(event, condition)
    end
  end
end
