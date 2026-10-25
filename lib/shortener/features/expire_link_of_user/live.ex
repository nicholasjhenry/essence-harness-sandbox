defmodule Shortener.Features.ExpireLinkOfUser.Live do
  @moduledoc """
  The page on which the owner of a link sets the time of expiration of the
  link. The owner is the user of the login session. The time is in UTC.
  """

  use ShortenerWeb, :live_view

  import ShortenerWeb.LinkComponents, only: [short_url_of: 1, time_text: 1]

  alias Shortener.Features.ExpireLinkOfUser.{Command, CommandHandler, OwnedLink}
  alias Shortener.Shared.Expiration

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
        Expire a link
        <:subtitle>From the time of expiration, the short URL goes to no target URL.</:subtitle>
      </.header>

      <dl class="space-y-2 mb-6">
        <div>
          <dt class="text-sm opacity-70">Short URL</dt>
          <dd id="expiration-short-url" class="break-all">{short_url_of(@owned.link)}</dd>
        </div>
        <div>
          <dt class="text-sm opacity-70">Target URL</dt>
          <dd class="break-all">{@owned.link.target_url}</dd>
        </div>
        <div>
          <dt class="text-sm opacity-70">Expires</dt>
          <dd id="expiration-current">{expires_text(@owned.expires_at)}</dd>
        </div>
      </dl>

      <.form for={@form} id="expire-link-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:expires_at]} type="datetime-local" label="Time of expiration (UTC)" />
        <.button variant="primary" phx-disable-with="Setting...">Set the expiration</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"command" => params}, socket) do
    changeset = Command.changeset(%Command{}, params, DateTime.utc_now())
    {:noreply, assign_form(socket, changeset, action: :validate)}
  end

  def handle_event("save", %{"command" => params}, socket) do
    now = DateTime.utc_now()
    changeset = Command.changeset(%Command{}, params, now)
    scope = socket.assigns.current_scope

    with {:ok, command} <- Ecto.Changeset.apply_action(changeset, :insert),
         {:ok, set} <- CommandHandler.handle(scope, socket.assigns.short_code, command, now) do
      {:noreply,
       socket
       |> put_flash(:info, "The link expires at #{time_text(set.expires_at)}.")
       |> push_navigate(to: ~p"/links")}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, :not_after_now} ->
        changeset =
          Ecto.Changeset.add_error(changeset, :expires_at, Command.not_after_now_message())

        {:noreply, assign_form(socket, changeset, action: :insert)}

      {:error, :not_found} ->
        {:noreply, leave(socket, not_found_message())}

      {:error, :expired} ->
        {:noreply, leave(socket, expired_message())}

      {:error, :not_logged_in} ->
        {:noreply,
         socket
         |> put_flash(:error, "Log in to expire a link.")
         |> redirect(to: ~p"/log-in")}

      {:error, :append_condition_failed} ->
        {:noreply, put_flash(socket, :error, "The link changed at the same time. Try again.")}
    end
  end

  defp show(socket, short_code, owned) do
    socket
    |> assign(:page_title, "Expire a link")
    |> assign(:short_code, short_code)
    |> assign(:owned, owned)
    |> assign_form(Command.changeset(%Command{}, %{}, DateTime.utc_now()))
  end

  defp leave(socket, message),
    do: socket |> put_flash(:error, message) |> push_navigate(to: ~p"/links")

  defp assign_form(socket, changeset, opts \\ []),
    do: assign(socket, :form, to_form(changeset, opts))

  defp not_found_message, do: "You own no link with this short code."
  defp expired_message, do: "The link has expired. Its time of expiration does not change."

  defp expires_text(nil), do: "Never"
  defp expires_text(expires_at), do: time_text(expires_at)
end
