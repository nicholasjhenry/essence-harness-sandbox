defmodule Shortener.Features.RedeemLoginTokenOfUser.LoginTokenStatus do
  @moduledoc """
  The state of one login token: `:unknown` if it was never sent,
  `{:sent, email_address, sent_at}` if it is not redeemed, or `:redeemed`.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{LoginLinkSent, LoginTokenRedeemed}

  @type t :: :unknown | {:sent, String.t(), DateTime.t()} | :redeemed

  @spec new(String.t()) :: Projection.t()
  def new(token_hash) do
    %Projection{
      initial_state: :unknown,
      handlers: %{
        LoginLinkSent.type_name() => fn _status, event ->
          sent = LoginLinkSent.from_event(event)
          {:sent, sent.email_address, sent.sent_at}
        end,
        LoginTokenRedeemed.type_name() => fn _status, _event -> :redeemed end
      },
      tags: [LoginLinkSent.login_token_tag(token_hash)]
    }
  end
end
