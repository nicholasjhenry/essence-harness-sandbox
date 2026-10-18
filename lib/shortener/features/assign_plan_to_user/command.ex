defmodule Shortener.Features.AssignPlanToUser.Command do
  @moduledoc """
  The request of a logged-in user to go on a plan.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Shortener.Shared.Plan

  @primary_key false
  embedded_schema do
    field :plan, :string
  end

  @type t :: %__MODULE__{plan: String.t()}

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(command, attrs) do
    command
    |> cast(attrs, [:plan])
    |> validate_required([:plan])
    |> validate_inclusion(:plan, Plan.names())
  end
end
