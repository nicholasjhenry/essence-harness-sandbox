defmodule Shortener.Projections.UserPlan do
  @moduledoc """
  The name of the plan of a user: the plan of the latest plan assignment of
  the user, or the default plan.
  """

  alias Shortener.DCB.Projection
  alias Shortener.Shared.{EmailAddress, Plan, PlanAssignedToUser}

  @spec new(String.t()) :: Projection.t()
  def new(email_address) do
    %Projection{
      initial_state: Plan.default().name,
      handlers: %{
        PlanAssignedToUser.type_name() => fn _plan, event ->
          PlanAssignedToUser.from_event(event).plan
        end
      },
      tags: [EmailAddress.tag(email_address)]
    }
  end
end
