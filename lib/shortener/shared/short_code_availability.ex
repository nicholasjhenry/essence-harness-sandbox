defmodule Shortener.Shared.ShortCodeAvailability do
  @moduledoc """
  The availability of a short code, for the form that makes a link, before
  the person submits it. A short code is taken if a link has it, or had it
  before its deletion, as for the decision of each shortening.

  It reads the events through the `ShortCodeClaimed` projection, and appends
  nothing. The decision at the submission checks the short code again.
  """

  alias Shortener.DCB.DecisionModel
  alias Shortener.Projections.ShortCodeClaimed
  alias Shortener.Shared.ShortCode

  @spec check(String.t() | nil) :: :available | :taken | nil
  def check(nil), do: nil

  def check(short_code) when is_binary(short_code),
    do: check(short_code, ShortCode.valid?(short_code))

  defp check(_value, false), do: nil

  defp check(short_code, true) do
    {model, _condition} =
      DecisionModel.build(Shortener.EventStore, claimed: ShortCodeClaimed.new(short_code))

    availability(model.claimed)
  end

  defp availability(true), do: :taken
  defp availability(false), do: :available
end
