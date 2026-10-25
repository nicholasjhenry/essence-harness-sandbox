defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.ResolvedLink do
  @moduledoc """
  The link of a short code, or `nil` if no link has the short code or the
  link is deleted.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{LinkDeleted, LinkShortened, ShortCode}

  @spec new(String.t()) :: Projection.t()
  def new(short_code) do
    %Projection{
      initial_state: nil,
      handlers: %{
        LinkShortened.type_name() => fn _link, event -> LinkShortened.from_event(event) end,
        LinkDeleted.type_name() => fn _link, _event -> nil end
      },
      tags: [ShortCode.tag(short_code)]
    }
  end
end
