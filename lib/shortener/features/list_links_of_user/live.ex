defmodule Shortener.Features.ListLinksOfUser.Live do
  @moduledoc """
  The page on which a logged-in user sees each link that the user owns, the
  newest first, with the number of its resolutions and its time of
  expiration. The owner is the user of the login session.

  The page subscribes to the resolutions of the links of the user. On each
  resolution, it reads the list again, so that the count changes with no
  reload. A short URL opens in a new browser tab, so that the page stays
  open.

  The page compares each time of expiration with the time of the last read.
  A time of expiration that passes while the page is open shows as past
  after the next read.
  """

  use ShortenerWeb, :live_view

  import ShortenerWeb.LinkComponents, only: [short_url_of: 1, time_text: 1]

  alias Shortener.Features.ListLinksOfUser.LinkList
  alias Shortener.Shared.{Expiration, ShortUrlResolved}

  @impl true
  def mount(_params, _session, socket) do
    email_address = socket.assigns.current_scope.user.email_address

    # The subscription comes before the read, so that no resolution between
    # the two is missed.
    if connected?(socket),
      do: Phoenix.PubSub.subscribe(Shortener.PubSub, ShortUrlResolved.topic(email_address))

    links = LinkList.of(email_address)

    {:ok,
     socket
     |> assign(:page_title, "All your links")
     |> assign(:now, DateTime.utc_now())
     |> assign(:links_empty?, links == [])
     |> stream(:links, links, dom_id: &"link-#{&1.link.short_code}")}
  end

  @impl true
  def handle_info({:short_url_resolved, _resolved}, socket) do
    links = LinkList.of(socket.assigns.current_scope.user.email_address)

    {:noreply,
     socket
     |> assign(:now, DateTime.utc_now())
     |> assign(:links_empty?, links == [])
     |> stream(:links, links, reset: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        All your links
        <:subtitle>Each link that you own, the newest first.</:subtitle>
      </.header>

      <p :if={@links_empty?} id="no-links">
        You own no links.
        <.link navigate={~p"/user-links"} class="link link-primary">Shorten a target URL</.link>
      </p>

      <.table :if={!@links_empty?} id="links" rows={@streams.links}>
        <:col :let={{_id, %{link: link}}} label="Short URL">
          <a
            href={short_url_of(link)}
            target="_blank"
            rel="noopener noreferrer"
            class="link link-primary break-all"
          >
            {short_url_of(link)}
          </a>
        </:col>
        <:col :let={{_id, %{link: link}}} label="Target URL">
          <span class="break-all">{link.target_url}</span>
        </:col>
        <:col :let={{_id, %{link: link}}} label="Shortened">
          {time_text(link.shortened_at)}
        </:col>
        <:col :let={{_id, listed}} label="Resolutions">
          <span id={"resolutions-#{listed.link.short_code}"}>{listed.resolution_count}</span>
        </:col>
        <:col :let={{_id, listed}} label="Expires">
          <span id={"expires-#{listed.link.short_code}"}>
            {expires_text(listed.expires_at, @now)}
          </span>
        </:col>
        <:action :let={{_id, listed}}>
          <.link
            :if={!Expiration.passed?(listed.expires_at, @now)}
            id={"expire-#{listed.link.short_code}"}
            navigate={~p"/links/#{listed.link.short_code}/expiration"}
          >
            {expire_text(listed.expires_at)}
          </.link>
        </:action>
        <:action :let={{_id, %{link: link}}}>
          <.link
            id={"delete-#{link.short_code}"}
            href={~p"/links/#{link.short_code}"}
            method="delete"
            data-confirm="Delete this link? Its short URL stops working."
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  defp expire_text(nil), do: "Expire"
  defp expire_text(_expires_at), do: "Change expiration"

  defp expires_text(nil, _now), do: "Never"

  defp expires_text(expires_at, now) do
    if Expiration.passed?(expires_at, now),
      do: "Expired #{time_text(expires_at)}",
      else: time_text(expires_at)
  end
end
