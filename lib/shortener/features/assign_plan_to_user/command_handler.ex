defmodule Shortener.Features.AssignPlanToUser.CommandHandler do
  @moduledoc """
  Puts a user on a plan, if the user is not on that plan.

  The decision reads the plan assignments of the user. A plan assignment of
  the same user between the read and the append fails the append, and the
  decision runs again.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.AssignPlanToUser.Command
  alias Shortener.Projections.UserPlan
  alias Shortener.Shared.PlanAssignedToUser

  @spec handle(Command.t(), DateTime.t()) ::
          {:ok, PlanAssignedToUser.t()}
          | {:error, :plan_already_assigned | :append_condition_failed}
  def handle(%Command{} = command, %DateTime{} = now) do
    projections = [user_plan: UserPlan.new(command.email_address)]

    with {:ok, [event]} <-
           Decider.run(Shortener.EventStore, projections, &decide(command, now, &1)) do
      {:ok, PlanAssignedToUser.from_event(event)}
    end
  end

  defp decide(%Command{plan: plan}, _now, %{user_plan: plan}),
    do: {:error, :plan_already_assigned}

  defp decide(%Command{} = command, now, _model) do
    fact = %PlanAssignedToUser{
      email_address: command.email_address,
      plan: command.plan,
      assigned_at: now
    }

    {:ok, [PlanAssignedToUser.to_event(fact)]}
  end
end
