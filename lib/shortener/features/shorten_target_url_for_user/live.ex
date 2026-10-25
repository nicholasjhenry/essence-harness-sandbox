defmodule Shortener.Features.ShortenTargetUrlForUser.Live do
  @moduledoc """
  The page on which a logged-in user shortens a target URL, and can choose
  the short code of the link. The user is the owner of the link.
  """

  use ShortenerWeb, :live_view

  import ShortenerWeb.LinkComponents

  alias Shortener.Features.ShortenTargetUrlForUser.{Command, CommandHandler, LinkUsage}
  alias Shortener.Shared.{LinkShortened, ShortCodeChoice}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Your links")
     |> assign(:link, nil)
     |> assign(:usage, LinkUsage.of(socket.assigns.current_scope.user.email_address))
     |> assign_form(Command.changeset(%Command{}, %{}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Your links
        <:subtitle>Each link counts toward the link limit of your plan.</:subtitle>
      </.header>

      <.form for={@form} id="shorten-for-user-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:target_url]}
          type="url"
          label="Target URL"
          placeholder="https://example.com/a/long/path"
          phx-debounce="300"
        />
        <.short_code_input field={@form[:short_code]} />
        <.button variant="primary" phx-disable-with="Shortening...">Shorten</.button>
      </.form>

      <.short_url :if={@link} link={@link} />

      <div :if={@usage} id="link-usage" class="text-sm">
        <span id="link-usage-count">{usage_text(@usage)}</span>
        on the <span id="link-usage-plan" class="font-semibold">{@usage.plan.title}</span>
        plan.
        <.link :if={@usage.plan.link_limit} navigate={~p"/plans"} class="link link-primary">
          Change the plan
        </.link>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"command" => params}, socket) do
    {:noreply, assign_form(socket, Command.changeset(%Command{}, params), action: :validate)}
  end

  def handle_event("save", %{"command" => params}, socket) do
    changeset = Command.changeset(%Command{}, params)
    scope = socket.assigns.current_scope

    with {:ok, command} <- Ecto.Changeset.apply_action(changeset, :insert),
         candidates = ShortCodeChoice.candidates(command.short_code),
         {:ok, %LinkShortened{} = link} <-
           CommandHandler.handle(scope, command, candidates, DateTime.utc_now()) do
      {:noreply,
       socket
       |> clear_flash()
       |> assign(:link, link)
       |> assign(:usage, LinkUsage.of(scope.user.email_address))
       |> assign_form(Command.changeset(%Command{}, %{}))}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:link, nil) |> assign_form(changeset)}

      {:error, :link_limit_reached} ->
        changeset =
          Ecto.Changeset.add_error(
            changeset,
            :target_url,
            "you have reached the link limit of your plan"
          )

        {:noreply,
         socket
         |> assign(:link, nil)
         |> assign(:usage, LinkUsage.of(scope.user.email_address))
         |> assign_form(changeset, action: :insert)}

      {:error, :not_logged_in} ->
        {:noreply,
         socket
         |> put_flash(:error, "Log in to open this page.")
         |> redirect(to: ~p"/log-in")}

      {:error, conflict} ->
        chosen = Ecto.Changeset.get_change(changeset, :short_code)
        {:noreply, socket |> assign(:link, nil) |> show_conflict(changeset, conflict, chosen)}
    end
  end

  defp show_conflict(socket, changeset, :short_code_taken, chosen) when is_binary(chosen) do
    changeset =
      Ecto.Changeset.add_error(
        changeset,
        :short_code,
        "is the short code of a link. Choose a different short code"
      )

    assign_form(socket, changeset, action: :insert)
  end

  defp show_conflict(socket, _changeset, _conflict, chosen) when is_binary(chosen),
    do: put_flash(socket, :error, "The link shortener could not save the link. Try again.")

  defp show_conflict(socket, _changeset, _conflict, nil),
    do: put_flash(socket, :error, "The link shortener could not make a short code. Try again.")

  defp assign_form(socket, changeset, opts \\ []),
    do: assign(socket, :form, to_form(changeset, opts))

  defp usage_text(%LinkUsage{link_count: count, plan: %{link_limit: nil}}), do: "#{count} links"

  defp usage_text(%LinkUsage{link_count: count, plan: %{link_limit: limit}}),
    do: "#{count} of #{limit} links"
end
