defmodule Shortener.Features.ListLinksOfUser.LinkExpirations do
  @moduledoc """
  The time of expiration of each link of the owner, by short code. A link
  with no expiration has no entry. The latest expiration of a link gives its
  time.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{EmailAddress, LinkExpirationSet}

  @spec new(String.t()) :: Projection.t()
  def new(email_address) do
    %Projection{
      initial_state: %{},
      handlers: %{
        LinkExpirationSet.type_name() => fn expirations, event ->
          expiration = LinkExpirationSet.from_event(event)
          Map.put(expirations, expiration.short_code, expiration.expires_at)
        end
      },
      tags: [EmailAddress.tag(email_address)]
    }
  end
end
