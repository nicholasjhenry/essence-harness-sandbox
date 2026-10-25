defmodule Shortener.Features.ChangeTargetUrlOfLink.Live do
  @moduledoc """
  The page on which the owner of a link replaces the target URL of the link
  with a new target URL. The owner is the user of the login session. The
  short code stays the same.

  The form compares the new target URL with the target URL that the mount
  read. The decision compares it with the target URL that the decision
  reads.
  """

  use ShortenerWeb, :live_view

  import ShortenerWeb.LinkComponents, only: [short_url_of: 1]

  alias Shortener.Features.ChangeTargetUrlOfLink.{Command, CommandHandler}
  alias Shortener.Shared.{Expiration, OwnedLink}

  @impl true
  def mount(%{"short_code" => short_code}, _session, socket) do
    email_address = socket.assigns.current_scope.user.email_address

    case OwnedLink.of(email_address, short_code) do
      {:ok, owned} ->
        if Expiration.passed?(owned.expires_at, DateTime.utc_now()),
          do: {:ok, leave(socket, expired_message())},
          else: {:ok, show(socket, short_code, owned)}

      {:error, :not_found} ->
        {:ok, leave(socket, not_found_message())}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Change a target URL
        <:subtitle>The short URL stays the same, and goes to the new target URL.</:subtitle>
      </.header>

      <dl class="space-y-2 mb-6">
        <div>
          <dt class="text-sm opacity-70">Short URL</dt>
          <dd id="change-target-url-short-url" class="break-all">{short_url_of(@owned.link)}</dd>
        </div>
        <div>
          <dt class="text-sm opacity-70">Target URL</dt>
          <dd id="change-target-url-current" class="break-all">{@owned.link.target_url}</dd>
        </div>
      </dl>

      <.form for={@form} id="change-target-url-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:target_url]}
          type="url"
          label="New target URL"
          phx-debounce="300"
        />
        <.button variant="primary" phx-disable-with="Changing...">Change the target URL</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"command" => params}, socket) do
    changeset = Command.changeset(%Command{}, params, current_target_url(socket))
    {:noreply, assign_form(socket, changeset, action: :validate)}
  end

  def handle_event("save", %{"command" => params}, socket) do
    changeset = Command.changeset(%Command{}, params, current_target_url(socket))
    scope = socket.assigns.current_scope

    with {:ok, command} <- Ecto.Changeset.apply_action(changeset, :insert),
         {:ok, changed} <-
           CommandHandler.handle(scope, socket.assigns.short_code, command, DateTime.utc_now()) do
      {:noreply,
       socket
       |> put_flash(:info, "The short URL now goes to #{changed.target_url}.")
       |> push_navigate(to: ~p"/links")}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, :unchanged} ->
        changeset =
          Ecto.Changeset.add_error(changeset, :target_url, Command.unchanged_message())

        {:noreply, assign_form(socket, changeset, action: :insert)}

      {:error, :not_found} ->
        {:noreply, leave(socket, not_found_message())}

      {:error, :expired} ->
        {:noreply, leave(socket, expired_message())}

      {:error, :not_logged_in} ->
        {:noreply,
         socket
         |> put_flash(:error, "Log in to change a target URL.")
         |> redirect(to: ~p"/log-in")}

      {:error, :append_condition_failed} ->
        {:noreply, put_flash(socket, :error, "The link changed at the same time. Try again.")}
    end
  end

  defp show(socket, short_code, owned) do
    target_url = owned.link.target_url

    socket
    |> assign(:page_title, "Change a target URL")
    |> assign(:short_code, short_code)
    |> assign(:owned, owned)
    |> assign_form(Command.changeset(%Command{target_url: target_url}, %{}, target_url))
  end

  defp current_target_url(socket), do: socket.assigns.owned.link.target_url

  defp leave(socket, message),
    do: socket |> put_flash(:error, message) |> push_navigate(to: ~p"/links")

  defp assign_form(socket, changeset, opts \\ []),
    do: assign(socket, :form, to_form(changeset, opts))

  defp not_found_message, do: "You own no link with this short code."
  defp expired_message, do: "The link has expired. Its target URL does not change."
end
