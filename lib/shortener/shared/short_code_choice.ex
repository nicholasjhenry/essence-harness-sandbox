defmodule Shortener.Shared.ShortCodeChoice do
  @moduledoc """
  The choice of the short code of a new link, from candidate short codes
  that the edge of the system makes. The decision takes the first candidate
  that no link has.
  """

  alias Shortener.DCB.DecisionModel
  alias Shortener.Projections.ShortCodeClaimed

  @doc "One projection for each candidate, keyed by `{:short_code_claimed, candidate}`."
  @spec projections([String.t(), ...]) :: DecisionModel.projections()
  def projections(candidates),
    do: Enum.map(candidates, &{{:short_code_claimed, &1}, ShortCodeClaimed.new(&1)})

  @spec first_free([String.t(), ...], map()) :: {:ok, String.t()} | {:error, :short_code_taken}
  def first_free(candidates, model) do
    case Enum.find(candidates, &(not Map.fetch!(model, {:short_code_claimed, &1}))) do
      nil -> {:error, :short_code_taken}
      short_code -> {:ok, short_code}
    end
  end
end
