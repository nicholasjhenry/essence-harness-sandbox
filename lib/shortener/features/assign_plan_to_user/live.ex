defmodule Shortener.Features.AssignPlanToUser.Live do
  @moduledoc """
  The page on which a person puts a user on a plan.
  """

  use ShortenerWeb, :live_view

  alias Shortener.Features.AssignPlanToUser.{Command, CommandHandler}
  alias Shortener.Shared.{Plan, PlanAssignedToUser}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Assign a plan")
     |> assign(:plan_options, Enum.map(Plan.all(), &{plan_label(&1), &1.name}))
     |> assign(:assignment, nil)
     |> assign_form(Command.changeset(%Command{}, %{"plan" => "pro"}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Assign a plan to a user
        <:subtitle>
          A user is known by an email address. A user with no plan is on the Free plan.
        </:subtitle>
      </.header>

      <.form for={@form} id="assign-plan-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:email_address]} type="email" label="Email address" phx-debounce="300" />
        <.input field={@form[:plan]} type="select" label="Plan" options={@plan_options} />
        <.button variant="primary" phx-disable-with="Assigning...">Assign the plan</.button>
      </.form>

      <div
        :if={@assignment}
        id="plan-assignment"
        class="rounded-box border border-success/40 bg-success/10 p-4"
      >
        <p class="font-semibold">
          <span id="plan-assignment-email">{@assignment.email_address}</span>
          is on the <span id="plan-assignment-plan">{plan_title(@assignment.plan)}</span>
          plan.
        </p>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"command" => params}, socket) do
    changeset = Command.changeset(%Command{}, params)
    {:noreply, assign_form(socket, changeset, action: :validate)}
  end

  def handle_event("save", %{"command" => params}, socket) do
    changeset = Command.changeset(%Command{}, params)

    with {:ok, command} <- Ecto.Changeset.apply_action(changeset, :insert),
         {:ok, %PlanAssignedToUser{} = assignment} <-
           CommandHandler.handle(command, DateTime.utc_now()) do
      {:noreply,
       socket
       |> assign(:assignment, assignment)
       |> assign_form(Command.changeset(%Command{}, %{"plan" => command.plan}))}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, :plan_already_assigned} ->
        changeset = Ecto.Changeset.add_error(changeset, :plan, "the user is on this plan")
        {:noreply, assign_form(socket, changeset, action: :insert)}

      {:error, :append_condition_failed} ->
        {:noreply,
         put_flash(socket, :error, "The plan of the user changed at the same time. Try again.")}
    end
  end

  defp assign_form(socket, changeset, opts \\ []),
    do: assign(socket, :form, to_form(changeset, opts))

  defp plan_label(%Plan{title: title, link_limit: nil}), do: "#{title} — any number of links"
  defp plan_label(%Plan{title: title, link_limit: limit}), do: "#{title} — #{limit} links"

  defp plan_title(name) do
    {:ok, plan} = Plan.fetch(name)
    plan.title
  end
end
