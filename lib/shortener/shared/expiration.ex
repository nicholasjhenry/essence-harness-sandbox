defmodule Shortener.Shared.Expiration do
  @moduledoc """
  The comparison of a time of expiration with the time now. The caller gives
  the time now, so that no projection reads the clock.
  """

  @doc """
  True if the time of expiration is at or before the time now. A link with
  no expiration has the time of expiration `nil`, which is never past.
  """
  @spec passed?(DateTime.t() | nil, DateTime.t()) :: boolean()
  def passed?(nil, %DateTime{}), do: false

  def passed?(%DateTime{} = expires_at, %DateTime{} = now),
    do: DateTime.compare(expires_at, now) != :gt
end
