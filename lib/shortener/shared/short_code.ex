defmodule Shortener.Shared.ShortCode do
  @moduledoc """
  The identifier of one link: seven characters from `A`–`Z`, `a`–`z`, and
  `0`–`9`. The link shortener makes it, or the person who shortens the
  target URL chooses it.
  """

  import Ecto.Changeset

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

  @doc """
  Validates the optional field of a chosen short code. Each space at the
  start and the end is removed. A field that is then empty is no change.
  """
  @spec validate(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def validate(changeset, field) do
    changeset
    |> update_change(field, &String.trim/1)
    |> drop_empty_change(field)
    |> validate_change(field, fn ^field, short_code ->
      if valid?(short_code),
        do: [],
        else: [{field, "must be seven characters from A–Z, a–z, and 0–9"}]
    end)
  end

  defp drop_empty_change(changeset, field) do
    case get_change(changeset, field) do
      "" -> delete_change(changeset, field)
      _short_code -> changeset
    end
  end

  @spec tag(String.t()) :: String.t()
  def tag(short_code), do: "short_code:" <> short_code
end
