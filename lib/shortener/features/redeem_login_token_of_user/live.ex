defmodule Shortener.Features.RedeemLoginTokenOfUser.Live do
  @moduledoc """
  The page of a login link. It shows one button, which posts the login
  token. The page itself redeems nothing, so a mail scanner that opens the
  link does not log in.
  """

  use ShortenerWeb, :live_view

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Log in")
     |> assign(:form, to_form(%{"token" => token}, as: "login"))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Log in
        <:subtitle>Select the button to log in on this browser.</:subtitle>
      </.header>

      <.form for={@form} id="redeem-form" action={~p"/log-in"}>
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
        <.button variant="primary" phx-disable-with="Logging in...">Log in</.button>
      </.form>
    </Layouts.app>
    """
  end
end
