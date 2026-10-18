defmodule Shortener.Features.SendLoginLinkToUser.Command do
  @moduledoc """
  The request of a person to get a login link for an email address.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Shortener.Shared.EmailAddress

  @primary_key false
  embedded_schema do
    field :email_address, :string
  end

  @type t :: %__MODULE__{email_address: String.t()}

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(command, attrs) do
    command
    |> cast(attrs, [:email_address])
    |> validate_required([:email_address])
    |> EmailAddress.validate(:email_address)
  end
end
