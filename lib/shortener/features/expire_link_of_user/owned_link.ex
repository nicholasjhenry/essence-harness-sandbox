defmodule Shortener.Features.ExpireLinkOfUser.OwnedLink do
  @moduledoc """
  The link of a short code with its time of expiration, if the user owns the
  link, for the page of the expiration.

  It reads the events through the `LinkOfShortCode` projection, and appends
  nothing.
  """

  alias Shortener.DCB.DecisionModel
  alias Shortener.Projections.LinkOfShortCode
  alias Shortener.Shared.ShortCode

  @spec of(String.t(), String.t()) :: {:ok, LinkOfShortCode.t()} | {:error, :not_found}
  def of(email_address, short_code) when is_binary(short_code) do
    if ShortCode.valid?(short_code),
      do: read(email_address, short_code),
      else: {:error, :not_found}
  end

  defp read(email_address, short_code) do
    {model, _condition} =
      DecisionModel.build(Shortener.EventStore, link: LinkOfShortCode.new(short_code))

    case model.link do
      %LinkOfShortCode{link: %{owner_email_address: ^email_address}} = link -> {:ok, link}
      _no_link_of_the_user -> {:error, :not_found}
    end
  end
end
