defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.Resolution do
  @moduledoc """
  Finds the target URL of the link of a short code.

  The resolution reads the event store, and appends nothing. A value that
  does not have the form of a short code is not read.
  """

  alias Shortener.DCB.DecisionModel
  alias Shortener.Features.ResolveTargetUrlOfShortUrl.LinkTarget
  alias Shortener.Shared.ShortCode

  @spec resolve(String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def resolve(short_code) do
    with true <- ShortCode.valid?(short_code),
         {%{link_target: target_url}, _condition} when is_binary(target_url) <-
           DecisionModel.build(Shortener.EventStore, link_target: LinkTarget.new(short_code)) do
      {:ok, target_url}
    else
      _not_found -> {:error, :not_found}
    end
  end
end
