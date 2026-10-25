defmodule Shortener.Shared.ShortCodeChoice do
  @moduledoc """
  The choice of the short code of a new link, from candidate short codes
  that the edge of the system gives: three short codes that the link
  shortener makes, or the one short code that the person chose. The
  decision takes the first candidate that no link has.
  """

  alias Shortener.DCB.DecisionModel
  alias Shortener.Projections.ShortCodeClaimed
  alias Shortener.Shared.ShortCode

  @generated 3

  @doc "The candidates of a decision: the chosen short code, or three new short codes."
  @spec candidates(String.t() | nil) :: [String.t(), ...]
  def candidates(nil), do: Enum.map(1..@generated, fn _ -> ShortCode.generate() end)
  def candidates(chosen) when is_binary(chosen), do: [chosen]

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
