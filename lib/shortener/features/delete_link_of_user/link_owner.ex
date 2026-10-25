defmodule Shortener.Features.DeleteLinkOfUser.LinkOwner do
  @moduledoc """
  The email address of the owner of the link of a short code, or `nil` if no
  link has the short code, the link has no owner, or the link is deleted.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{LinkDeleted, LinkShortened, ShortCode}

  @spec new(String.t()) :: Projection.t()
  def new(short_code) do
    %Projection{
      initial_state: nil,
      handlers: %{
        LinkShortened.type_name() => fn _owner, event ->
          LinkShortened.from_event(event).owner_email_address
        end,
        LinkDeleted.type_name() => fn _owner, _event -> nil end
      },
      tags: [ShortCode.tag(short_code)]
    }
  end
end
