defmodule Shortener.Features.ShortenTargetUrlForUser.Live do
  @moduledoc """
  The page on which a person shortens a target URL for a user.
  """

  use ShortenerWeb, :live_view

  import ShortenerWeb.LinkComponents

  alias Shortener.Features.ShortenTargetUrlForUser.{Command, CommandHandler, LinkUsage}
  alias Shortener.Shared.{LinkShortened, ShortCode}

  @candidates 3

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Shorten a link for a user")
     |> assign(:link, nil)
     |> assign(:usage, nil)
     |> assign_form(Command.changeset(%Command{}, %{}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Shorten a link for a user
        <:subtitle>The link counts toward the link limit of the plan of the user.</:subtitle>
      </.header>

      <.form for={@form} id="shorten-for-user-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:email_address]} type="email" label="Email address" phx-debounce="300" />
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
    candidates = Enum.map(1..@candidates, fn _ -> ShortCode.generate() end)

    with {:ok, command} <- Ecto.Changeset.apply_action(changeset, :insert),
         {:ok, %LinkShortened{} = link} <-
           CommandHandler.handle(command, candidates, DateTime.utc_now()) do
      {:noreply,
       socket
       |> clear_flash()
       |> assign(:link, link)
       |> assign(:usage, LinkUsage.of(command.email_address))
       |> assign_form(Command.changeset(%Command{}, %{"email_address" => command.email_address}))}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:link, nil) |> assign(:usage, nil) |> assign_form(changeset)}

      {:error, :link_limit_reached} ->
        email_address = Ecto.Changeset.get_field(changeset, :email_address)

        changeset =
          Ecto.Changeset.add_error(
            changeset,
            :email_address,
            "the user has reached the link limit of the plan"
          )

        {:noreply,
         socket
         |> assign(:link, nil)
         |> assign(:usage, LinkUsage.of(email_address))
         |> assign_form(changeset, action: :insert)}

      {:error, _conflict} ->
        {:noreply,
         socket
         |> assign(:link, nil)
         |> assign(:usage, nil)
         |> put_flash(:error, "The link shortener could not make a short code. Try again.")}
    end
  end

  defp assign_form(socket, changeset, opts \\ []),
    do: assign(socket, :form, to_form(changeset, opts))

  defp usage_text(%LinkUsage{link_count: count, plan: %{link_limit: nil}}), do: "#{count} links"

  defp usage_text(%LinkUsage{link_count: count, plan: %{link_limit: limit}}),
    do: "#{count} of #{limit} links"
end
