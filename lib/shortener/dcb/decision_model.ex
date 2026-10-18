defmodule Shortener.DCB.DecisionModel do
  @moduledoc """
  The state that one command decides on, composed from projections.

  The query of the decision model is the union of the query items of its
  projections. Nobody writes it by hand. The same query is the append
  condition, after the last position that the read gave.
  """

  alias Shortener.DCB.{AppendCondition, Projection, Query}

  @type projections :: [{term(), Projection.t()}]

  @spec build(module(), projections()) :: {map(), AppendCondition.t()}
  def build(store, projections) do
    query = %Query{
      items: Enum.map(projections, fn {_key, projection} -> Projection.query_item(projection) end)
    }

    events = store.read(query, [])

    state =
      Map.new(projections, fn {key, projection} ->
        {key,
         Enum.reduce(
           events,
           projection.initial_state,
           &Projection.apply_event(projection, &2, &1.event)
         )}
      end)

    last_position = events |> List.last() |> then(&(&1 && &1.position))
    {state, %AppendCondition{fail_if_events_match: query, after: last_position}}
  end
end
