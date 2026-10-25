defmodule Shortener.Shared.LinkDeleted do
  @moduledoc """
  The event of a deletion: the link shortener removed the link of one short
  code, at the request of its owner, at one time.

  The event is tagged with the tag of the short code and with the tag of the
  owner, so that each projection of the link or of the owner reads it.
  """

  alias Shortener.DCB.Event
  alias Shortener.Shared.{EmailAddress, ShortCode}

  @type_name "LinkDeleted"

  @enforce_keys [:short_code, :owner_email_address, :deleted_at]
  defstruct [:short_code, :owner_email_address, :deleted_at]

  @type t :: %__MODULE__{
          short_code: String.t(),
          owner_email_address: String.t(),
          deleted_at: DateTime.t()
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
          deleted_at: fact.deleted_at |> DateTime.shift_zone!("Etc/UTC") |> DateTime.to_iso8601()
        }),
      tags: [ShortCode.tag(fact.short_code), EmailAddress.tag(fact.owner_email_address)]
    }
  end

  @spec from_event(Event.t()) :: t()
  def from_event(%Event{type: @type_name, data: data}) do
    %{
      "short_code" => short_code,
      "owner_email_address" => owner_email_address,
      "deleted_at" => deleted_at
    } = Jason.decode!(data)

    {:ok, deleted_at, 0} = DateTime.from_iso8601(deleted_at)

    %__MODULE__{
      short_code: short_code,
      owner_email_address: owner_email_address,
      deleted_at: deleted_at
    }
  end
end
