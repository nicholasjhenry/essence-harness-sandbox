defmodule Shortener.Projections.LoginSessionUser do
  @moduledoc """
  The email address of the user of a login session, or `nil` if the login
  session was never started or is ended.
  """

  alias Shortener.DCB.{DecisionModel, Projection}
  alias Shortener.Shared.{LoginSessionEnded, LoginTokenRedeemed}

  @spec new(String.t()) :: Projection.t()
  def new(session_token_hash) do
    %Projection{
      initial_state: nil,
      handlers: %{
        LoginTokenRedeemed.type_name() => fn _user, event ->
          LoginTokenRedeemed.from_event(event).email_address
        end,
        LoginSessionEnded.type_name() => fn _user, _event -> nil end
      },
      tags: [LoginTokenRedeemed.login_session_tag(session_token_hash)]
    }
  end

  @doc "Reads the email address of the user of a login session, and appends nothing."
  @spec of(String.t()) :: String.t() | nil
  def of(session_token_hash) do
    {model, _condition} =
      DecisionModel.build(Shortener.EventStore, user: new(session_token_hash))

    model.user
  end
end
