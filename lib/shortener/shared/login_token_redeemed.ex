defmodule Shortener.Shared.LoginTokenRedeemed do
  @moduledoc """
  The event of a redemption: the link shortener accepted one login token,
  and started one login session for its user, at one time.

  The event holds the hash of the login token and the hash of the session
  token. It is tagged with the tag of the login token, the tag of the user,
  and the tag of the login session.
  """

  alias Shortener.DCB.Event
  alias Shortener.Shared.{EmailAddress, LoginLinkSent}

  @type_name "LoginTokenRedeemed"

  @enforce_keys [:email_address, :token_hash, :session_token_hash, :redeemed_at]
  defstruct [:email_address, :token_hash, :session_token_hash, :redeemed_at]

  @type t :: %__MODULE__{
          email_address: String.t(),
          token_hash: String.t(),
          session_token_hash: String.t(),
          redeemed_at: DateTime.t()
        }

  @spec type_name() :: String.t()
  def type_name, do: @type_name

  @spec login_session_tag(String.t()) :: String.t()
  def login_session_tag(session_token_hash), do: "login_session:" <> session_token_hash

  @spec to_event(t()) :: Event.t()
  def to_event(%__MODULE__{} = fact) do
    %Event{
      type: @type_name,
      data:
        Jason.encode!(%{
          email_address: fact.email_address,
          token_hash: fact.token_hash,
          session_token_hash: fact.session_token_hash,
          redeemed_at:
            fact.redeemed_at |> DateTime.shift_zone!("Etc/UTC") |> DateTime.to_iso8601()
        }),
      tags: [
        LoginLinkSent.login_token_tag(fact.token_hash),
        EmailAddress.tag(fact.email_address),
        login_session_tag(fact.session_token_hash)
      ]
    }
  end

  @spec from_event(Event.t()) :: t()
  def from_event(%Event{type: @type_name, data: data}) do
    %{
      "email_address" => email_address,
      "token_hash" => token_hash,
      "session_token_hash" => session_token_hash,
      "redeemed_at" => redeemed_at
    } = Jason.decode!(data)

    {:ok, redeemed_at, 0} = DateTime.from_iso8601(redeemed_at)

    %__MODULE__{
      email_address: email_address,
      token_hash: token_hash,
      session_token_hash: session_token_hash,
      redeemed_at: redeemed_at
    }
  end
end
