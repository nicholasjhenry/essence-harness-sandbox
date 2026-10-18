defmodule Shortener.Shared.Scope do
  @moduledoc """
  Who acts in a request: the user of a login session, and the hash of its
  session token.

  A decision that needs the login session reads it again by the hash, so
  that a logout in a different browser tab stops the decision.
  """

  alias Shortener.Shared.User

  @enforce_keys [:user, :session_token_hash]
  defstruct [:user, :session_token_hash]

  @type t :: %__MODULE__{user: User.t(), session_token_hash: String.t()}

  @spec for_user(User.t() | nil, String.t()) :: t() | nil
  def for_user(%User{} = user, session_token_hash),
    do: %__MODULE__{user: user, session_token_hash: session_token_hash}

  def for_user(nil, _session_token_hash), do: nil
end
