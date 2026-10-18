defmodule Shortener.DCB.Query do
  @moduledoc """
  A set of query items. An event matches the query if it matches one of its
  items. `all/0` gives the query that matches each event.
  """

  alias Shortener.DCB.{Event, QueryItem}

  defstruct items: [], all?: false

  @type t :: %__MODULE__{items: [QueryItem.t()], all?: boolean()}

  @spec all() :: t()
  def all, do: %__MODULE__{all?: true}

  @spec matches?(t(), Event.t()) :: boolean()
  def matches?(%__MODULE__{all?: true}, %Event{}), do: true

  def matches?(%__MODULE__{items: items}, %Event{} = event),
    do: Enum.any?(items, &item_matches?(&1, event))

  defp item_matches?(%QueryItem{types: types, tags: tags}, %Event{} = event) do
    (types == [] or event.type in types) and Enum.all?(tags, &(&1 in event.tags))
  end
end
