defmodule Shortener.Projections.LinkOfShortCode do
  @moduledoc """
  The link of a short code and its time of expiration, or `nil` if no link
  has the short code or the link is deleted. A link with no expiration has
  the time of expiration `nil`.

  `link.target_url` is the current target URL of the link: the target URL of
  the latest target URL change, and not always the target URL of the
  `LinkShortened` event.

  The projection does not compare the time of expiration with the time now.
  The decision that reads it does, with the time that it is given.
  """

  alias Shortener.DCB.Projection

  alias Shortener.Shared.{
    LinkDeleted,
    LinkExpirationSet,
    LinkShortened,
    LinkTargetUrlChanged,
    ShortCode
  }

  @enforce_keys [:link]
  defstruct [:link, :expires_at]

  @type t :: %__MODULE__{link: LinkShortened.t(), expires_at: DateTime.t() | nil}

  @spec new(String.t()) :: Projection.t()
  def new(short_code) do
    %Projection{
      initial_state: nil,
      handlers: %{
        LinkShortened.type_name() => fn _state, event ->
          %__MODULE__{link: LinkShortened.from_event(event)}
        end,
        LinkDeleted.type_name() => fn _state, _event -> nil end,
        LinkExpirationSet.type_name() => &expire/2,
        LinkTargetUrlChanged.type_name() => &change_target_url/2
      },
      tags: [ShortCode.tag(short_code)]
    }
  end

  defp expire(nil, _event), do: nil

  defp expire(%__MODULE__{} = state, event),
    do: %{state | expires_at: LinkExpirationSet.from_event(event).expires_at}

  defp change_target_url(nil, _event), do: nil

  defp change_target_url(%__MODULE__{link: link} = state, event),
    do: %{state | link: %{link | target_url: LinkTargetUrlChanged.from_event(event).target_url}}
end
