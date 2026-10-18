defmodule Shortener.Shared.TargetUrl do
  @moduledoc """
  The URL that a person gives to the link shortener to shorten: an absolute
  URL with the `http` or the `https` scheme and a host.
  """

  import Ecto.Changeset

  @max_length 2048

  @doc "Validates that the field holds a target URL."
  @spec validate(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def validate(changeset, field) do
    changeset
    |> update_change(field, &String.trim/1)
    |> validate_length(field, max: @max_length)
    |> validate_change(field, fn ^field, url ->
      if valid?(url), do: [], else: [{field, "must be an http or https URL with a host"}]
    end)
  end

  @spec valid?(String.t()) :: boolean()
  def valid?(url) do
    case URI.new(url) do
      {:ok, %URI{scheme: scheme, host: host}}
      when scheme in ["http", "https"] and is_binary(host) ->
        host != ""

      _other ->
        false
    end
  end
end
