defmodule Shortener.Features.ShortenTargetUrlForUser.LinkUsage do
  @moduledoc """
  The plan of a user and the number of links of the user, for the page.

  It reads the same projections as the decision, and appends nothing.
  """

  alias Shortener.DCB.DecisionModel
  alias Shortener.Features.ShortenTargetUrlForUser.UserLinkCount
  alias Shortener.Projections.UserPlan
  alias Shortener.Shared.Plan

  @enforce_keys [:plan, :link_count]
  defstruct [:plan, :link_count]

  @type t :: %__MODULE__{plan: Plan.t(), link_count: non_neg_integer()}

  @spec of(String.t()) :: t()
  def of(email_address) do
    {model, _condition} =
      DecisionModel.build(Shortener.EventStore,
        user_plan: UserPlan.new(email_address),
        user_link_count: UserLinkCount.new(email_address)
      )

    {:ok, plan} = Plan.fetch(model.user_plan)
    %__MODULE__{plan: plan, link_count: model.user_link_count}
  end
end
