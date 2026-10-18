defmodule Shortener.Features.AssignPlanToUser.PlanOfUser do
  @moduledoc """
  The plan of a user, for the page. It reads the same projection as the
  decision, and appends nothing.
  """

  alias Shortener.DCB.DecisionModel
  alias Shortener.Projections.UserPlan
  alias Shortener.Shared.Plan

  @spec of(String.t()) :: Plan.t()
  def of(email_address) do
    {model, _condition} =
      DecisionModel.build(Shortener.EventStore, user_plan: UserPlan.new(email_address))

    {:ok, plan} = Plan.fetch(model.user_plan)
    plan
  end
end
