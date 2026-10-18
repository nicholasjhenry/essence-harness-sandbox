defmodule Shortener.Features.EndLoginSessionOfUser.CommandHandler do
  @moduledoc """
  Ends the login session of a session token. A session token of no login
  session, or of an ended one, appends nothing.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Projections.LoginSessionUser
  alias Shortener.Shared.{LoginSessionEnded, Secret}

  @spec handle(String.t(), DateTime.t()) :: :ok | {:error, :append_condition_failed}
  def handle(session_token, %DateTime{} = now) when is_binary(session_token) do
    session_token_hash = Secret.hash(session_token)
    projections = [user: LoginSessionUser.new(session_token_hash)]

    case Decider.run(Shortener.EventStore, projections, &decide(session_token_hash, now, &1)) do
      {:ok, _events} -> :ok
      {:error, :no_login_session} -> :ok
      {:error, :append_condition_failed} = error -> error
    end
  end

  defp decide(_session_token_hash, _now, %{user: nil}), do: {:error, :no_login_session}

  defp decide(session_token_hash, now, _model) do
    fact = %LoginSessionEnded{session_token_hash: session_token_hash, ended_at: now}
    {:ok, [LoginSessionEnded.to_event(fact)]}
  end
end
