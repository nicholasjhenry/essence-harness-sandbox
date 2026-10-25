defmodule Shortener.Features.ShortenTargetUrlForUser.UserLinkCount do
  @moduledoc """
  The number of links of which the user is the owner. A deleted link is
  not counted.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{EmailAddress, LinkDeleted, LinkShortened}

  @spec new(String.t()) :: Projection.t()
  def new(email_address) do
    %Projection{
      initial_state: 0,
      handlers: %{
        LinkShortened.type_name() => fn count, _event -> count + 1 end,
        LinkDeleted.type_name() => fn count, _event -> count - 1 end
      },
      tags: [EmailAddress.tag(email_address)]
    }
  end
end
