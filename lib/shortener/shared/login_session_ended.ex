defmodule Shortener.Shared.LoginSessionEnded do
  @moduledoc """
  The event of a logout: the link shortener ended one login session, at one
  time. It is tagged with the tag of the login session.
  """

  alias Shortener.DCB.Event
  alias Shortener.Shared.LoginTokenRedeemed

  @type_name "LoginSessionEnded"

  @enforce_keys [:session_token_hash, :ended_at]
  defstruct [:session_token_hash, :ended_at]

  @type t :: %__MODULE__{session_token_hash: String.t(), ended_at: DateTime.t()}

  @spec type_name() :: String.t()
  def type_name, do: @type_name

  @spec to_event(t()) :: Event.t()
  def to_event(%__MODULE__{} = fact) do
    %Event{
      type: @type_name,
      data:
        Jason.encode!(%{
          session_token_hash: fact.session_token_hash,
          ended_at: fact.ended_at |> DateTime.shift_zone!("Etc/UTC") |> DateTime.to_iso8601()
        }),
      tags: [LoginTokenRedeemed.login_session_tag(fact.session_token_hash)]
    }
  end

  @spec from_event(Event.t()) :: t()
  def from_event(%Event{type: @type_name, data: data}) do
    %{"session_token_hash" => session_token_hash, "ended_at" => ended_at} = Jason.decode!(data)
    {:ok, ended_at, 0} = DateTime.from_iso8601(ended_at)
    %__MODULE__{session_token_hash: session_token_hash, ended_at: ended_at}
  end
end
