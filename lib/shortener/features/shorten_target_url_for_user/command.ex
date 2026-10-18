defmodule Shortener.Features.ShortenTargetUrlForUser.Command do
  @moduledoc """
  The request to shorten a target URL for a user, who is the owner of the
  link.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Shortener.Shared.{EmailAddress, TargetUrl}

  @primary_key false
  embedded_schema do
    field :email_address, :string
    field :target_url, :string
  end

  @type t :: %__MODULE__{email_address: String.t(), target_url: String.t()}

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(command, attrs) do
    command
    |> cast(attrs, [:email_address, :target_url])
    |> validate_required([:email_address, :target_url])
    |> EmailAddress.validate(:email_address)
    |> TargetUrl.validate(:target_url)
  end
end
