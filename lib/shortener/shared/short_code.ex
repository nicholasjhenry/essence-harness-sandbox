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
  @byte_limit 256 - rem(256, Kernel.length(@alphabet))

  @spec generate() :: String.t()
  def generate, do: generate([])

  defp generate(characters) when Kernel.length(characters) == @length,
    do: List.to_string(characters)

  defp generate(characters) do
    usable =
      for <<byte <- :crypto.strong_rand_bytes(@length)>>, byte < @byte_limit do
        Enum.at(@alphabet, rem(byte, Kernel.length(@alphabet)))
      end

    generate(Enum.take(characters ++ usable, @length))
  end

  @doc "The number of characters of a short code."
  @spec length() :: pos_integer()
  def length, do: @length

  @doc "True if the value has the form of a short code."
  @spec valid?(term()) :: boolean()
  def valid?(value) when is_binary(value), do: value =~ format()

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
    |> validate_format(field, format(),
      message: "must be seven characters from A–Z, a–z, and 0–9"
    )
  end

  # The form of a short code: seven characters of the alphabet. The regex is
  # built in a function, because Elixir deprecates a regex in a module
  # attribute on Erlang/OTP 28.
  defp format, do: ~r/\A[A-Za-z0-9]{#{@length}}\z/

  defp drop_empty_change(changeset, field) do
    case get_change(changeset, field) do
      "" -> delete_change(changeset, field)
      _short_code -> changeset
    end
  end

  @spec tag(String.t()) :: String.t()
  def tag(short_code), do: "short_code:" <> short_code
end
