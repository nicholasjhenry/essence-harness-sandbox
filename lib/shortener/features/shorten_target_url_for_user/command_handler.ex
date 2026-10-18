defmodule Shortener.Features.ShortenTargetUrlForUser.CommandHandler do
  @moduledoc """
  Makes a link for a target URL, with the user as owner, if the number of
  links of the user is less than the link limit of the plan of the user.

  The decision reads the candidate short codes, the plan assignments of the
  user, and the links of the user. A plan assignment or a link of the same
  user between the read and the append fails the append, and the decision
  runs again.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.ShortenTargetUrlForUser.{Command, UserLinkCount}
  alias Shortener.Projections.UserPlan
  alias Shortener.Shared.{LinkShortened, Plan, ShortCodeChoice}

  @spec handle(Command.t(), [String.t(), ...], DateTime.t()) ::
          {:ok, LinkShortened.t()}
          | {:error, :link_limit_reached | :short_code_taken | :append_condition_failed}
  def handle(%Command{} = command, [_ | _] = candidates, %DateTime{} = now) do
    projections =
      ShortCodeChoice.projections(candidates) ++
        [
          user_plan: UserPlan.new(command.email_address),
          user_link_count: UserLinkCount.new(command.email_address)
        ]

    with {:ok, [event]} <-
           Decider.run(Shortener.EventStore, projections, &decide(command, candidates, now, &1)) do
      {:ok, LinkShortened.from_event(event)}
    end
  end

  defp decide(%Command{} = command, candidates, now, model) do
    {:ok, plan} = Plan.fetch(model.user_plan)

    with :ok <- within_link_limit(plan, model.user_link_count),
         {:ok, short_code} <- ShortCodeChoice.first_free(candidates, model) do
      fact = %LinkShortened{
        short_code: short_code,
        target_url: command.target_url,
        owner_email_address: command.email_address,
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
