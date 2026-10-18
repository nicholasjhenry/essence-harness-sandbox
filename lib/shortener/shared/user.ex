defmodule Shortener.Shared.User do
  @moduledoc """
  A person whom the link shortener knows by one email address.
  """

  @enforce_keys [:email_address]
  defstruct [:email_address]

  @type t :: %__MODULE__{email_address: String.t()}
end
