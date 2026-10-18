defmodule Shortener.DCB.Event do
  @moduledoc """
  A fact that happened: its type, its data, and the tags of its subjects.

  The data is a binary that the event store does not parse.
  """

  @enforce_keys [:type, :data, :tags]
  defstruct [:type, :data, tags: []]

  @type t :: %__MODULE__{type: String.t(), data: binary(), tags: [String.t()]}
end
