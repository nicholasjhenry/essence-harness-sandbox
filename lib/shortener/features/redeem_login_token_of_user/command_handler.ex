defmodule Shortener.Features.RedeemLoginTokenOfUser.CommandHandler do
  @moduledoc """
  Accepts a login token, and starts a login session for its user, if the
  login token was sent, is not redeemed, and is in its lifetime.

  The decision reads the events of the login token. A second redemption of
  the same login token between the read and the append fails the append,
  and the decision runs again.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.RedeemLoginTokenOfUser.LoginTokenStatus
  alias Shortener.Shared.{LoginTokenRedeemed, Secret}

  # The lifetime of a login token, in seconds.
  @lifetime 15 * 60

  @spec handle(String.t(), String.t(), DateTime.t()) ::
          {:ok, String.t()} | {:error, :invalid_token | :append_condition_failed}
  def handle(token, session_token, %DateTime{} = now)
      when is_binary(token) and is_binary(session_token) do
    token_hash = Secret.hash(token)
    projections = [login_token: LoginTokenStatus.new(token_hash)]

    with {:ok, [event]} <-
           Decider.run(
             Shortener.EventStore,
             projections,
             &decide(token_hash, Secret.hash(session_token), now, &1)
           ) do
      {:ok, LoginTokenRedeemed.from_event(event).email_address}
    end
  end

  defp decide(token_hash, session_token_hash, now, %{login_token: {:sent, email_address, sent_at}}) do
    if DateTime.compare(now, DateTime.add(sent_at, @lifetime, :second)) != :gt do
      fact = %LoginTokenRedeemed{
        email_address: email_address,
        token_hash: token_hash,
        session_token_hash: session_token_hash,
        redeemed_at: now
      }

      {:ok, [LoginTokenRedeemed.to_event(fact)]}
    else
      {:error, :invalid_token}
    end
  end

  defp decide(_token_hash, _session_token_hash, _now, _model), do: {:error, :invalid_token}
end
