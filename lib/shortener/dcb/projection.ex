defmodule Shortener.DCB.Projection do
  @moduledoc """
  A pure fold of events into one value, which answers one question.

  A projection has an initial state, one handler for each event type, and
  the tags it is read for. Its query item follows from the handlers and the
  tags.
  """

  alias Shortener.DCB.{Event, QueryItem}

  @enforce_keys [:initial_state, :handlers]
  defstruct [:initial_state, :handlers, tags: []]

  @type handler :: (term(), Event.t() -> term())
  @type t :: %__MODULE__{
          initial_state: term(),
          handlers: %{String.t() => handler()},
          tags: [String.t()]
        }

  @spec query_item(t()) :: QueryItem.t()
  def query_item(%__MODULE__{handlers: handlers, tags: tags}),
    do: %QueryItem{types: Map.keys(handlers), tags: tags}

  @doc """
  Applies the event to the state, if the event has a handler and carries
  each tag of the projection. Otherwise the state does not change.
  """
  @spec apply_event(t(), term(), Event.t()) :: term()
  def apply_event(%__MODULE__{handlers: handlers, tags: tags}, state, %Event{} = event) do
    handler = Map.get(handlers, event.type)

    if handler && Enum.all?(tags, &(&1 in event.tags)),
      do: handler.(state, event),
      else: state
  end
end
