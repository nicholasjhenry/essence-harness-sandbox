defmodule Shortener.Features.ExpireLinkOfUser.Command do
  @moduledoc """
  The request of the owner of a link to set its time of expiration. The time
  is in UTC, as a `datetime-local` field of a form sends it.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :expires_at, :utc_datetime
  end

  @type t :: %__MODULE__{expires_at: DateTime.t() | nil}

  @doc "The error of a time of expiration that is not after the time now."
  @spec not_after_now_message() :: String.t()
  def not_after_now_message, do: "must be after the time now"

  @spec changeset(t(), map(), DateTime.t()) :: Ecto.Changeset.t()
  def changeset(command, attrs, %DateTime{} = now) do
    command
    |> cast(attrs, [:expires_at])
    |> validate_required([:expires_at])
    |> validate_after(:expires_at, now)
  end

  defp validate_after(changeset, field, now) do
    validate_change(changeset, field, fn ^field, time ->
      if DateTime.after?(time, now), do: [], else: [{field, not_after_now_message()}]
    end)
  end
end
