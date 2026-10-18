defmodule Shortener.Features.SendLoginLinkToUser.CommandHandler do
  @moduledoc """
  Records a new login token for an email address.

  No hard constraint applies to a new login token, so the decision model is
  empty. The event holds the hash of the login token.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.SendLoginLinkToUser.Command
  alias Shortener.Shared.{LoginLinkSent, Secret}

  @spec handle(Command.t(), String.t(), DateTime.t()) ::
          {:ok, LoginLinkSent.t()} | {:error, :append_condition_failed}
  def handle(%Command{} = command, token, %DateTime{} = now) when is_binary(token) do
    fact = %LoginLinkSent{
      email_address: command.email_address,
      token_hash: Secret.hash(token),
      sent_at: now
    }

    with {:ok, [event]} <-
           Decider.run(Shortener.EventStore, [], fn _model ->
             {:ok, [LoginLinkSent.to_event(fact)]}
           end) do
      {:ok, LoginLinkSent.from_event(event)}
    end
  end
end
