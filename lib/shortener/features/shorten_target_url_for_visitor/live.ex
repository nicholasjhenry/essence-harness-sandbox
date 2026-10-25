defmodule Shortener.Features.ShortenTargetUrlForVisitor.Live do
  @moduledoc """
  The page on which a visitor shortens a target URL, and can choose the
  short code of the link.
  """

  use ShortenerWeb, :live_view

  import ShortenerWeb.LinkComponents

  alias Shortener.Features.ShortenTargetUrlForVisitor.{Command, CommandHandler}
  alias Shortener.Shared.{LinkShortened, ShortCodeAvailability, ShortCodeChoice}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Shorten a link")
     |> assign(:link, nil)
     |> assign(:availability, nil)
     |> assign_form(Command.changeset(%Command{}, %{}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Shorten a link
        <:subtitle>Paste a long URL, and get a short URL for it.</:subtitle>
      </.header>

      <.form for={@form} id="shorten-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:target_url]}
          type="url"
          label="Target URL"
          placeholder="https://example.com/a/long/path"
          phx-debounce="300"
        />
        <.short_code_input field={@form[:short_code]} availability={@availability} />
        <.button variant="primary" phx-disable-with="Shortening...">Shorten</.button>
      </.form>

      <.short_url :if={@link} link={@link} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"command" => params}, socket) do
    changeset = Command.changeset(%Command{}, params)

    {:noreply,
     socket
     |> assign_form(changeset, action: :validate)
     |> assign_availability(changeset)}
  end

  def handle_event("save", %{"command" => params}, socket) do
    changeset = Command.changeset(%Command{}, params)
    socket = assign(socket, :availability, nil)

    with {:ok, command} <- Ecto.Changeset.apply_action(changeset, :insert),
         candidates = ShortCodeChoice.candidates(command.short_code),
         {:ok, %LinkShortened{} = link} <-
           CommandHandler.handle(command, candidates, DateTime.utc_now()) do
      {:noreply,
       socket
       |> clear_flash()
       |> assign(:link, link)
       |> assign_form(Command.changeset(%Command{}, %{}))}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:link, nil)
         |> assign_form(changeset)
         |> assign_availability(changeset)}

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

  defp assign_availability(socket, changeset) do
    short_code = Ecto.Changeset.get_change(changeset, :short_code)
    assign(socket, :availability, ShortCodeAvailability.check(short_code))
  end
end
