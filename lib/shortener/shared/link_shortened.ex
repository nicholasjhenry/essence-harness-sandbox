defmodule Shortener.Shared.LinkShortened do
  @moduledoc """
  The event of a link: the link shortener made a short code for a target
  URL, at one time. A link that a visitor shortens has no owner.

  The event is tagged with the tag of the short code, and with the tag of
  the owner if the link has an owner.
  """

  alias Shortener.DCB.Event
  alias Shortener.Shared.{EmailAddress, ShortCode}

  @type_name "LinkShortened"

  @enforce_keys [:short_code, :target_url, :shortened_at]
  defstruct [:short_code, :target_url, :owner_email_address, :shortened_at]

  @type t :: %__MODULE__{
          short_code: String.t(),
          target_url: String.t(),
          owner_email_address: String.t() | nil,
          shortened_at: DateTime.t()
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
          target_url: fact.target_url,
          owner_email_address: fact.owner_email_address,
          shortened_at:
            fact.shortened_at |> DateTime.shift_zone!("Etc/UTC") |> DateTime.to_iso8601()
        }),
      tags: tags(fact)
    }
  end

  @spec from_event(Event.t()) :: t()
  def from_event(%Event{type: @type_name, data: data}) do
    %{
      "short_code" => short_code,
      "target_url" => target_url,
      "owner_email_address" => owner_email_address,
      "shortened_at" => shortened_at
    } = Jason.decode!(data)

    {:ok, shortened_at, 0} = DateTime.from_iso8601(shortened_at)

    %__MODULE__{
      short_code: short_code,
      target_url: target_url,
      owner_email_address: owner_email_address,
      shortened_at: shortened_at
    }
  end

  defp tags(%__MODULE__{short_code: short_code, owner_email_address: nil}),
    do: [ShortCode.tag(short_code)]

  defp tags(%__MODULE__{short_code: short_code, owner_email_address: owner}),
    do: [ShortCode.tag(short_code), EmailAddress.tag(owner)]
end
