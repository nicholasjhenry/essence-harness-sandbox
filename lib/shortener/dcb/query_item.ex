defmodule Shortener.DCB.QueryItem do
  @moduledoc """
  One part of a query. An event matches the item if its type is one of the
  types of the item and its tags include each tag of the item. An item with
  no types matches each type.
  """

  defstruct types: [], tags: []

  @type t :: %__MODULE__{types: [String.t()], tags: [String.t()]}
end
