defmodule Shortener.Shared.ShortCode do
  @moduledoc """
  The identifier of one link: seven characters from `A`–`Z`, `a`–`z`, and
  `0`–`9`, which the link shortener makes.
  """

  @alphabet ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  @length 7
  # The largest multiple of the size of the alphabet below 256. A random
  # byte at or above it is not used, so that each character is equally
  # probable.
  @byte_limit 256 - rem(256, length(@alphabet))

  @spec generate() :: String.t()
  def generate, do: generate([])

  defp generate(characters) when length(characters) == @length, do: List.to_string(characters)

  defp generate(characters) do
    usable =
      for <<byte <- :crypto.strong_rand_bytes(@length)>>, byte < @byte_limit do
        Enum.at(@alphabet, rem(byte, length(@alphabet)))
      end

    generate(Enum.take(characters ++ usable, @length))
  end

  @doc "True if the value has the form of a short code."
  @spec valid?(term()) :: boolean()
  def valid?(value) when is_binary(value),
    do: byte_size(value) == @length and value |> to_charlist() |> Enum.all?(&(&1 in @alphabet))

  def valid?(_value), do: false

  @spec tag(String.t()) :: String.t()
  def tag(short_code), do: "short_code:" <> short_code
end
