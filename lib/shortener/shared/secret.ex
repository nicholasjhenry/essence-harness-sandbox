defmodule Shortener.Shared.Secret do
  @moduledoc """
  A secret of the login: a login token or a session token.

  A secret is 32 random bytes, in URL-safe Base64 with no padding. The
  link shortener keeps only the SHA-256 hash of a secret, in an event and
  in its tag.
  """

  @bytes 32

  @spec generate() :: String.t()
  def generate, do: @bytes |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

  @spec hash(String.t()) :: String.t()
  def hash(secret), do: Base.encode16(:crypto.hash(:sha256, secret), case: :lower)
end
