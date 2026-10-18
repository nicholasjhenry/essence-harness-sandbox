defmodule Shortener.Features.AssignPlanToUser.Live do
  @moduledoc """
  The page on which a logged-in user selects the plan of that user.
  """

  use ShortenerWeb, :live_view

  alias Shortener.Features.AssignPlanToUser.{Command, CommandHandler, PlanOfUser}
  alias Shortener.Shared.{Plan, PlanAssignedToUser}

  @impl true
  def mount(_params, _session, socket) do
    plan = PlanOfUser.of(socket.assigns.current_scope.user.email_address)

    {:ok,
     socket
     |> assign(:page_title, "Your plan")
     |> assign(:plan_options, Enum.map(Plan.all(), &{plan_label(&1), &1.name}))
     |> assign(:plan, plan)
     |> assign_form(Command.changeset(%Command{}, %{"plan" => plan.name}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Your plan
        <:subtitle>
          <span id="current-plan-email">{@current_scope.user.email_address}</span>
          is on the <span id="current-plan" class="font-semibold">{@plan.title}</span>
          plan.
        </:subtitle>
      </.header>

      <.form for={@form} id="assign-plan-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:plan]} type="select" label="Plan" options={@plan_options} />
        <.button variant="primary" phx-disable-with="Changing...">Change the plan</.button>
      </.form>
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
    scope = socket.assigns.current_scope

    with {:ok, command} <- Ecto.Changeset.apply_action(changeset, :insert),
         {:ok, %PlanAssignedToUser{plan: name}} <-
           CommandHandler.handle(scope, command, DateTime.utc_now()) do
      {:ok, plan} = Plan.fetch(name)

      {:noreply,
       socket
       |> assign(:plan, plan)
       |> put_flash(:info, "You are on the #{plan.title} plan.")
       |> assign_form(Command.changeset(%Command{}, %{"plan" => name}))}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, :plan_already_assigned} ->
        changeset = Ecto.Changeset.add_error(changeset, :plan, "you are on this plan")
        {:noreply, assign_form(socket, changeset, action: :insert)}

      {:error, :not_logged_in} ->
        {:noreply,
         socket
         |> put_flash(:error, "Log in to open this page.")
         |> redirect(to: ~p"/log-in")}

      {:error, :append_condition_failed} ->
        {:noreply, put_flash(socket, :error, "Your plan changed at the same time. Try again.")}
    end
  end

  defp assign_form(socket, changeset, opts \\ []),
    do: assign(socket, :form, to_form(changeset, opts))

  defp plan_label(%Plan{title: title, link_limit: nil}), do: "#{title} — any number of links"
  defp plan_label(%Plan{title: title, link_limit: limit}), do: "#{title} — #{limit} links"
end
