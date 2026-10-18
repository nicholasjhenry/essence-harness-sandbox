defmodule Shortener.Shared.LoginLinkSent do
  @moduledoc """
  The event of a login link: the link shortener made a login token for one
  email address, and sent it by email, at one time.

  The event holds the hash of the login token, and not the login token. It
  is tagged with the tag of the login token and the tag of the user.
  """

  alias Shortener.DCB.Event
  alias Shortener.Shared.EmailAddress

  @type_name "LoginLinkSent"

  @enforce_keys [:email_address, :token_hash, :sent_at]
  defstruct [:email_address, :token_hash, :sent_at]

  @type t :: %__MODULE__{email_address: String.t(), token_hash: String.t(), sent_at: DateTime.t()}

  @spec type_name() :: String.t()
  def type_name, do: @type_name

  @spec login_token_tag(String.t()) :: String.t()
  def login_token_tag(token_hash), do: "login_token:" <> token_hash

  @spec to_event(t()) :: Event.t()
  def to_event(%__MODULE__{} = fact) do
    %Event{
      type: @type_name,
      data:
        Jason.encode!(%{
          email_address: fact.email_address,
          token_hash: fact.token_hash,
          sent_at: fact.sent_at |> DateTime.shift_zone!("Etc/UTC") |> DateTime.to_iso8601()
        }),
      tags: [login_token_tag(fact.token_hash), EmailAddress.tag(fact.email_address)]
    }
  end

  @spec from_event(Event.t()) :: t()
  def from_event(%Event{type: @type_name, data: data}) do
    %{"email_address" => email_address, "token_hash" => token_hash, "sent_at" => sent_at} =
      Jason.decode!(data)

    {:ok, sent_at, 0} = DateTime.from_iso8601(sent_at)
    %__MODULE__{email_address: email_address, token_hash: token_hash, sent_at: sent_at}
  end
end
