defmodule Shortener.Features.ShortenTargetUrlForVisitor.Live do
  @moduledoc """
  The page on which a visitor shortens a target URL.
  """

  use ShortenerWeb, :live_view

  import ShortenerWeb.LinkComponents

  alias Shortener.Features.ShortenTargetUrlForVisitor.{Command, CommandHandler}
  alias Shortener.Shared.{LinkShortened, ShortCode}

  @candidates 3

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Shorten a link")
     |> assign(:link, nil)
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
        <.button variant="primary" phx-disable-with="Shortening...">Shorten</.button>
      </.form>

      <.short_url :if={@link} link={@link} />
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"command" => params}, socket) do
    {:noreply, assign_form(socket, Command.changeset(%Command{}, params), action: :validate)}
  end

  def handle_event("save", %{"command" => params}, socket) do
    changeset = Command.changeset(%Command{}, params)
    candidates = Enum.map(1..@candidates, fn _ -> ShortCode.generate() end)

    with {:ok, command} <- Ecto.Changeset.apply_action(changeset, :insert),
         {:ok, %LinkShortened{} = link} <-
           CommandHandler.handle(command, candidates, DateTime.utc_now()) do
      {:noreply,
       socket
       |> clear_flash()
       |> assign(:link, link)
       |> assign_form(Command.changeset(%Command{}, %{}))}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:link, nil) |> assign_form(changeset)}

      {:error, _conflict} ->
        {:noreply,
         socket
         |> assign(:link, nil)
         |> put_flash(:error, "The link shortener could not make a short code. Try again.")}
    end
  end

  defp assign_form(socket, changeset, opts \\ []),
    do: assign(socket, :form, to_form(changeset, opts))
end
