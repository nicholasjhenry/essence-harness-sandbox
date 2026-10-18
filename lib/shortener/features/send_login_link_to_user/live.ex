defmodule Shortener.Features.SendLoginLinkToUser.Live do
  @moduledoc """
  The page on which a person asks for a login link.
  """

  use ShortenerWeb, :live_view

  alias Shortener.Features.SendLoginLinkToUser.{Command, CommandHandler, LoginEmail}
  alias Shortener.Mailer
  alias Shortener.Shared.Secret

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Log in")
     |> assign(:sent_to, nil)
     |> assign_form(Command.changeset(%Command{}, %{}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Log in
        <:subtitle>We send a login link to your email address. You need no password.</:subtitle>
      </.header>

      <.form for={@form} id="login-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:email_address]} type="email" label="Email address" phx-debounce="300" />
        <.button variant="primary" phx-disable-with="Sending...">Send the login link</.button>
      </.form>

      <div
        :if={@sent_to}
        id="login-link-sent"
        class="rounded-box border border-success/40 bg-success/10 p-4"
      >
        A login link is on its way to <span class="font-semibold">{@sent_to}</span>.
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
    token = Secret.generate()

    with {:ok, command} <- Ecto.Changeset.apply_action(changeset, :insert),
         {:ok, _sent} <- CommandHandler.handle(command, token, DateTime.utc_now()),
         {:ok, _email} <-
           Mailer.deliver(LoginEmail.new(command.email_address, url(~p"/log-in/#{token}"))) do
      {:noreply,
       socket
       |> assign(:sent_to, command.email_address)
       |> assign_form(Command.changeset(%Command{}, %{}))}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:sent_to, nil) |> assign_form(changeset)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> assign(:sent_to, nil)
         |> put_flash(:error, "The link shortener could not send the login link. Try again.")}
    end
  end

  defp assign_form(socket, changeset, opts \\ []),
    do: assign(socket, :form, to_form(changeset, opts))
end
