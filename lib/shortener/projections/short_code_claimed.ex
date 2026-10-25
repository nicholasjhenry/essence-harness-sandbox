defmodule Shortener.Projections.ShortCodeClaimed do
  @moduledoc """
  True if a link has the short code, or had it before its deletion. It reads
  no deletion, so no new link gets the short code of a deleted link.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{LinkShortened, ShortCode}

  @spec new(String.t()) :: Projection.t()
  def new(short_code) do
    %Projection{
      initial_state: false,
      handlers: %{LinkShortened.type_name() => fn _claimed, _event -> true end},
      tags: [ShortCode.tag(short_code)]
    }
  end
end
