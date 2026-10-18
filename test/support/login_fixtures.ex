defmodule Shortener.LoginFixtures do
  @moduledoc """
  The login of a user for a test: a sent login link and its redemption.
  """

  alias Shortener.Features.RedeemLoginTokenOfUser.CommandHandler
  alias Shortener.Shared.{EmailAddress, LoginLinkSent, Secret}
  alias ShortenerWeb.UserAuth

  @doc "Starts a login session for the email address, and gives its session token."
  @spec start_login_session(String.t()) :: String.t()
  def start_login_session(email_address) do
    token = Secret.generate()
    session_token = Secret.generate()
    now = DateTime.utc_now()

    sent = %LoginLinkSent{
      email_address: EmailAddress.normalize(email_address),
      token_hash: Secret.hash(token),
      sent_at: now
    }

    :ok = Shortener.EventStore.append(LoginLinkSent.to_event(sent), nil)
    {:ok, _email_address} = CommandHandler.handle(token, session_token, now)
    session_token
  end

  @doc "The scope of a new login session of the email address."
  @spec login_scope(String.t()) :: Shortener.Shared.Scope.t()
  def login_scope(email_address),
    do: email_address |> start_login_session() |> UserAuth.scope_for_session_token()
end
