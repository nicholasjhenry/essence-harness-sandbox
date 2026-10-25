defmodule Shortener.Shared.LinkTargetUrlChanged do
  @moduledoc """
  The event of a target URL change: the owner of a link replaced the target
  URL of the link with a new target URL, at one time. From the change, the
  short URL of the link resolves to the new target URL. The short code stays
  the same.

  The event is tagged with the tag of the short code and with the tag of the
  owner, so that each projection of the link or of the owner reads it.
  """

  alias Shortener.DCB.Event
  alias Shortener.Shared.{EmailAddress, ShortCode}

  @type_name "LinkTargetUrlChanged"

  @enforce_keys [:short_code, :owner_email_address, :target_url, :changed_at]
  defstruct [:short_code, :owner_email_address, :target_url, :changed_at]

  @typedoc """
  ## Fields

  - target_url: the new target URL of the link
  - changed_at: the time of change
  """
  @type t :: %__MODULE__{
          short_code: String.t(),
          owner_email_address: String.t(),
          target_url: String.t(),
          changed_at: DateTime.t()
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
          target_url: fact.target_url,
          changed_at: fact.changed_at |> DateTime.shift_zone!("Etc/UTC") |> DateTime.to_iso8601()
        }),
      tags: [ShortCode.tag(fact.short_code), EmailAddress.tag(fact.owner_email_address)]
    }
  end

  @spec from_event(Event.t()) :: t()
  def from_event(%Event{type: @type_name, data: data}) do
    %{
      "short_code" => short_code,
      "owner_email_address" => owner_email_address,
      "target_url" => target_url,
      "changed_at" => changed_at
    } = Jason.decode!(data)

    {:ok, changed_at, 0} = DateTime.from_iso8601(changed_at)

    %__MODULE__{
      short_code: short_code,
      owner_email_address: owner_email_address,
      target_url: target_url,
      changed_at: changed_at
    }
  end
end
