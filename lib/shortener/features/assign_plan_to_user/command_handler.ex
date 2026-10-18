defmodule Shortener.Features.AssignPlanToUser.CommandHandler do
  @moduledoc """
  Puts the user of the scope on a plan, if the login session of the scope
  is not ended and the user is not on that plan.

  The decision reads the plan assignments of the user and the login session
  of the scope. A plan assignment of the same user, or the logout of the
  login session, between the read and the append fails the append, and the
  decision runs again.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.AssignPlanToUser.Command
  alias Shortener.Projections.{LoginSessionUser, UserPlan}
  alias Shortener.Shared.{PlanAssignedToUser, Scope}

  @spec handle(Scope.t(), Command.t(), DateTime.t()) ::
          {:ok, PlanAssignedToUser.t()}
          | {:error, :not_logged_in | :plan_already_assigned | :append_condition_failed}
  def handle(%Scope{} = scope, %Command{} = command, %DateTime{} = now) do
    email_address = scope.user.email_address

    projections = [
      user_plan: UserPlan.new(email_address),
      login_session: LoginSessionUser.new(scope.session_token_hash)
    ]

    with {:ok, [event]} <-
           Decider.run(
             Shortener.EventStore,
             projections,
             &decide(email_address, command, now, &1)
           ) do
      {:ok, PlanAssignedToUser.from_event(event)}
    end
  end

  defp decide(email_address, _command, _now, %{login_session: user})
       when user != email_address,
       do: {:error, :not_logged_in}

  defp decide(_email_address, %Command{plan: plan}, _now, %{user_plan: plan}),
    do: {:error, :plan_already_assigned}

  defp decide(email_address, %Command{} = command, now, _model) do
    fact = %PlanAssignedToUser{email_address: email_address, plan: command.plan, assigned_at: now}
    {:ok, [PlanAssignedToUser.to_event(fact)]}
  end
end
