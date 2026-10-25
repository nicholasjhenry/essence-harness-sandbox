defmodule Shortener.Shared.LinkExpirationSet do
  @moduledoc """
  The event of an expiration: the owner of a link set the time of expiration
  of the link, at one time. From the time of expiration, the short URL of the
  link resolves to no target URL.

  The event is tagged with the tag of the short code and with the tag of the
  owner, so that each projection of the link or of the owner reads it.
  """

  alias Shortener.DCB.Event
  alias Shortener.Shared.{EmailAddress, ShortCode}

  @type_name "LinkExpirationSet"

  @enforce_keys [:short_code, :owner_email_address, :expires_at, :set_at]
  defstruct [:short_code, :owner_email_address, :expires_at, :set_at]

  @type t :: %__MODULE__{
          short_code: String.t(),
          owner_email_address: String.t(),
          expires_at: DateTime.t(),
          set_at: DateTime.t()
        }

  @spec type_name() :: String.t()
  def type_name, do: @type_name

  @spec to_event(t()) :: Event.t()
  def to_event(%__MODULE__{} = fact) do
    %Event{
      type: @type_name,
      data:
        Jason.encode!(%{
          short_code: fact.short_code,
          owner_email_address: fact.owner_email_address,
          expires_at: iso8601(fact.expires_at),
          set_at: iso8601(fact.set_at)
        }),
      tags: [ShortCode.tag(fact.short_code), EmailAddress.tag(fact.owner_email_address)]
    }
  end

  @spec from_event(Event.t()) :: t()
  def from_event(%Event{type: @type_name, data: data}) do
    %{
      "short_code" => short_code,
      "owner_email_address" => owner_email_address,
      "expires_at" => expires_at,
      "set_at" => set_at
    } = Jason.decode!(data)

    {:ok, expires_at, 0} = DateTime.from_iso8601(expires_at)
    {:ok, set_at, 0} = DateTime.from_iso8601(set_at)

    %__MODULE__{
      short_code: short_code,
      owner_email_address: owner_email_address,
      expires_at: expires_at,
      set_at: set_at
    }
  end

  defp iso8601(time), do: time |> DateTime.shift_zone!("Etc/UTC") |> DateTime.to_iso8601()
end
