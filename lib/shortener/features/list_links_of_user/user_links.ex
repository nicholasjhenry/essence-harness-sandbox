defmodule Shortener.Features.ListLinksOfUser.UserLinks do
  @moduledoc """
  The links of which the user is the owner, the newest first.

  The event store gives the events in the order of their positions, so each
  link goes to the start of the list.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{EmailAddress, LinkShortened}

  @spec new(String.t()) :: Projection.t()
  def new(email_address) do
    %Projection{
      initial_state: [],
      handlers: %{
        LinkShortened.type_name() => fn links, event ->
          [LinkShortened.from_event(event) | links]
        end
      },
      tags: [EmailAddress.tag(email_address)]
    }
  end
end
