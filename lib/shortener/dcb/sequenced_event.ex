defmodule Shortener.DCB.SequencedEvent do
  @moduledoc """
  An event as the event store gives it, with its sequence position.
  """

  alias Shortener.DCB.Event

  @enforce_keys [:event, :position]
  defstruct [:event, :position]

  @type t :: %__MODULE__{event: Event.t(), position: pos_integer()}
end
