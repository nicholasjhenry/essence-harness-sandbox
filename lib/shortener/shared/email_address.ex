defmodule Shortener.Shared.EmailAddress do
  @moduledoc """
  The email address that identifies a user.

  Two email addresses that differ only in case, or in spaces at the ends,
  identify the same user. The tag of a user holds the SHA-256 hash of the
  normalized email address, and not the email address in clear.
  """

  import Ecto.Changeset

  @format ~r/^[^\s@]+@[^\s@]+$/

  @spec normalize(String.t()) :: String.t()
  def normalize(email_address), do: email_address |> String.trim() |> String.downcase()

  @spec tag(String.t()) :: String.t()
  def tag(email_address) do
    "user:" <> Base.encode16(:crypto.hash(:sha256, normalize(email_address)), case: :lower)
  end

  @doc "Validates that the field holds an email address of the form `name@domain`."
  @spec validate(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def validate(changeset, field) do
    changeset
    |> update_change(field, &normalize/1)
    |> validate_format(field, @format, message: "must have the form name@domain")
    |> validate_length(field, max: 254)
  end
end
