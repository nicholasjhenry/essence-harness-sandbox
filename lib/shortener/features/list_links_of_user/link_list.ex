defmodule Shortener.Features.ListLinksOfUser.LinkList do
  @moduledoc """
  The links of a user, the newest first, each with the number of its
  resolutions and its time of expiration, for the page.

  It reads the events through the `UserLinks`, the `ResolutionCounts`, and
  the `LinkExpirations` projections, in one read, and appends nothing.
  """

  alias Shortener.DCB.DecisionModel

  alias Shortener.Features.ListLinksOfUser.{
    LinkExpirations,
    ListedLink,
    ResolutionCounts,
    UserLinks
  }

  @spec of(String.t()) :: [ListedLink.t()]
  def of(email_address) do
    {model, _condition} =
      DecisionModel.build(Shortener.EventStore,
        user_links: UserLinks.new(email_address),
        resolution_counts: ResolutionCounts.new(email_address),
        link_expirations: LinkExpirations.new(email_address)
      )

    Enum.map(model.user_links, fn link ->
      %ListedLink{
        link: link,
        resolution_count: Map.get(model.resolution_counts, link.short_code, 0),
        expires_at: Map.get(model.link_expirations, link.short_code)
      }
    end)
  end
end
