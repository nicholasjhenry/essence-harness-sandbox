defmodule Shortener.Features.ListLinksOfUser.LinkList do
  @moduledoc """
  The links of a user, the newest first, for the page.

  It reads the events through the `UserLinks` projection, and appends
  nothing.
  """

  alias Shortener.DCB.DecisionModel
  alias Shortener.Features.ListLinksOfUser.UserLinks
  alias Shortener.Shared.LinkShortened

  @spec of(String.t()) :: [LinkShortened.t()]
  def of(email_address) do
    {model, _condition} =
      DecisionModel.build(Shortener.EventStore, user_links: UserLinks.new(email_address))

    model.user_links
  end
end
