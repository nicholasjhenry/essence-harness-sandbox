defmodule Shortener.DCB.AppendCondition do
  @moduledoc """
  The condition of an append. The append fails if an event after the
  position `after` matches `fail_if_events_match`. With no `after`, the
  append fails if any event matches.
  """

  alias Shortener.DCB.Query

  @enforce_keys [:fail_if_events_match]
  defstruct [:fail_if_events_match, :after]

  @type t :: %__MODULE__{fail_if_events_match: Query.t(), after: pos_integer() | nil}
end
