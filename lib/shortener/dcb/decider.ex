defmodule Shortener.DCB.Decider do
  @moduledoc """
  Runs one command: builds its decision model, decides, and appends the
  events under the append condition.

  If an event that matches the query arrives between the read and the
  append, the append fails. The decider then reads, decides, and appends
  again, up to `@attempts` times in all.
  """

  alias Shortener.DCB.{DecisionModel, Event}

  @attempts 3

  @type decide :: (map() -> {:ok, [Event.t()]} | {:error, term()})

  @spec run(module(), DecisionModel.projections(), decide()) ::
          {:ok, [Event.t()]} | {:error, term()}
  def run(store, projections, decide), do: run(store, projections, decide, @attempts)

  defp run(store, projections, decide, attempts) do
    {state, condition} = DecisionModel.build(store, projections)

    with {:ok, events} <- decide.(state),
         :ok <- store.append(events, condition) do
      {:ok, events}
    else
      {:error, :append_condition_failed} when attempts > 1 ->
        run(store, projections, decide, attempts - 1)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
