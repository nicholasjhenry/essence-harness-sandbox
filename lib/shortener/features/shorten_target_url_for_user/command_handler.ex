defmodule Shortener.Features.ShortenTargetUrlForUser.CommandHandler do
  @moduledoc """
  Makes a link for a target URL, with the user of the scope as owner, if
  the login session of the scope is not ended, and the number of links of
  the user is less than the link limit of the plan of the user.

  The decision reads the candidate short codes, the plan assignments of the
  user, the links of the user, and the login session of the scope. A plan
  assignment or a link of the same user, or the logout of the login
  session, between the read and the append fails the append, and the
  decision runs again.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.ShortenTargetUrlForUser.{Command, UserLinkCount}
  alias Shortener.Projections.{LoginSessionUser, UserPlan}
  alias Shortener.Shared.{LinkShortened, Plan, Scope, ShortCodeChoice}

  @spec handle(Scope.t(), Command.t(), [String.t(), ...], DateTime.t()) ::
          {:ok, LinkShortened.t()}
          | {:error,
             :not_logged_in
             | :link_limit_reached
             | :short_code_taken
             | :append_condition_failed}
  def handle(%Scope{} = scope, %Command{} = command, [_ | _] = candidates, %DateTime{} = now) do
    email_address = scope.user.email_address

    projections =
      ShortCodeChoice.projections(candidates) ++
        [
          user_plan: UserPlan.new(email_address),
          user_link_count: UserLinkCount.new(email_address),
          login_session: LoginSessionUser.new(scope.session_token_hash)
        ]

    with {:ok, [event]} <-
           Decider.run(
             Shortener.EventStore,
             projections,
             &decide(email_address, command, candidates, now, &1)
           ) do
      {:ok, LinkShortened.from_event(event)}
    end
  end

  defp decide(email_address, _command, _candidates, _now, %{login_session: user})
       when user != email_address,
       do: {:error, :not_logged_in}

  defp decide(email_address, %Command{} = command, candidates, now, model) do
    {:ok, plan} = Plan.fetch(model.user_plan)

    with :ok <- within_link_limit(plan, model.user_link_count),
         {:ok, short_code} <- ShortCodeChoice.first_free(candidates, model) do
      fact = %LinkShortened{
        short_code: short_code,
        target_url: command.target_url,
        owner_email_address: email_address,
        shortened_at: now
      }

      {:ok, [LinkShortened.to_event(fact)]}
    end
  end

  defp within_link_limit(%Plan{link_limit: nil}, _link_count), do: :ok

  defp within_link_limit(%Plan{link_limit: link_limit}, link_count) when link_count < link_limit,
    do: :ok

  defp within_link_limit(%Plan{}, _link_count), do: {:error, :link_limit_reached}
end
