defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.LinkTarget do
  @moduledoc """
  The target URL of the link of a short code, or `nil` if no link has the
  short code.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{LinkShortened, ShortCode}

  @spec new(String.t()) :: Projection.t()
  def new(short_code) do
    %Projection{
      initial_state: nil,
      handlers: %{
        LinkShortened.type_name() => fn _target_url, event ->
          LinkShortened.from_event(event).target_url
        end
      },
      tags: [ShortCode.tag(short_code)]
    }
  end
end
