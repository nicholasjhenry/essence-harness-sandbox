defmodule Shortener.Features.ListLinksOfUser.UserLinks do
  @moduledoc """
  The links of which the user is the owner, the newest first. A deleted
  link is not in the list.

  The event store gives the events in the order of their positions, so each
  link goes to the start of the list.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{EmailAddress, LinkDeleted, LinkShortened}

  @spec new(String.t()) :: Projection.t()
  def new(email_address) do
    %Projection{
      initial_state: [],
      handlers: %{
        LinkShortened.type_name() => fn links, event ->
          [LinkShortened.from_event(event) | links]
        end,
        LinkDeleted.type_name() => fn links, event ->
          short_code = LinkDeleted.from_event(event).short_code
          Enum.reject(links, &(&1.short_code == short_code))
        end
      },
      tags: [EmailAddress.tag(email_address)]
    }
  end
end
