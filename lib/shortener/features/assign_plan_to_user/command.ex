defmodule Shortener.Features.AssignPlanToUser.Command do
  @moduledoc """
  The request to put a user on a plan.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Shortener.Shared.{EmailAddress, Plan}

  @primary_key false
  embedded_schema do
    field :email_address, :string
    field :plan, :string
  end

  @type t :: %__MODULE__{email_address: String.t(), plan: String.t()}

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(command, attrs) do
    command
    |> cast(attrs, [:email_address, :plan])
    |> validate_required([:email_address, :plan])
    |> EmailAddress.validate(:email_address)
    |> validate_inclusion(:plan, Plan.names())
  end
end
