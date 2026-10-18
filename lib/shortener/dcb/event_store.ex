defmodule Shortener.DCB.EventStore do
  @moduledoc """
  The two operations of a DCB event store.

  `c:read/2` gives the sequenced events that match a query, in position
  order. The option `:after` gives only the events after a position.

  `c:append/2` writes the events in one atomic operation. It fails with
  `{:error, :append_condition_failed}` if an event matches the condition.
  """

  alias Shortener.DCB.{AppendCondition, Event, Query, SequencedEvent}

  @callback read(Query.t(), keyword()) :: [SequencedEvent.t()]
  @callback append(Event.t() | [Event.t(), ...], AppendCondition.t() | nil) ::
              :ok | {:error, :append_condition_failed}
end
