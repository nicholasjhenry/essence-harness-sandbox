defmodule Shortener.Shared.PlanAssignedToUser do
  @moduledoc """
  The event of a plan assignment: the link shortener put one user on one
  plan, at one time. It is tagged with the tag of the user.
  """

  alias Shortener.DCB.Event
  alias Shortener.Shared.EmailAddress

  @type_name "PlanAssignedToUser"

  @enforce_keys [:email_address, :plan, :assigned_at]
  defstruct [:email_address, :plan, :assigned_at]

  @type t :: %__MODULE__{email_address: String.t(), plan: String.t(), assigned_at: DateTime.t()}

  @spec type_name() :: String.t()
  def type_name, do: @type_name

  @spec to_event(t()) :: Event.t()
  def to_event(%__MODULE__{} = fact) do
    %Event{
      type: @type_name,
      data:
        Jason.encode!(%{
          email_address: fact.email_address,
          plan: fact.plan,
          assigned_at:
            fact.assigned_at |> DateTime.shift_zone!("Etc/UTC") |> DateTime.to_iso8601()
        }),
      tags: [EmailAddress.tag(fact.email_address)]
    }
  end

  @spec from_event(Event.t()) :: t()
  def from_event(%Event{type: @type_name, data: data}) do
    %{"email_address" => email_address, "plan" => plan, "assigned_at" => assigned_at} =
      Jason.decode!(data)

    {:ok, assigned_at, 0} = DateTime.from_iso8601(assigned_at)
    %__MODULE__{email_address: email_address, plan: plan, assigned_at: assigned_at}
  end
end
