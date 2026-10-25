defmodule Shortener.Features.ListLinksOfUser.ResolutionCounts do
  @moduledoc """
  The number of resolutions of each link of the owner, by short code. A
  link with no resolution has no entry.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{EmailAddress, ShortUrlResolved}

  @spec new(String.t()) :: Projection.t()
  def new(email_address) do
    %Projection{
      initial_state: %{},
      handlers: %{
        ShortUrlResolved.type_name() => fn counts, event ->
          short_code = ShortUrlResolved.from_event(event).short_code
          Map.update(counts, short_code, 1, &(&1 + 1))
        end
      },
      tags: [EmailAddress.tag(email_address)]
    }
  end
end
