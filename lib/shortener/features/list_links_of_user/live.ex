defmodule Shortener.Features.ListLinksOfUser.Live do
  @moduledoc """
  The page on which a logged-in user sees each link that the user owns, the
  newest first, with the number of its resolutions. The owner is the user
  of the login session.
  """

  use ShortenerWeb, :live_view

  import ShortenerWeb.LinkComponents, only: [short_url_of: 1]

  alias Shortener.Features.ListLinksOfUser.LinkList

  @impl true
  def mount(_params, _session, socket) do
    links = LinkList.of(socket.assigns.current_scope.user.email_address)

    {:ok,
     socket
     |> assign(:page_title, "All your links")
     |> assign(:links_empty?, links == [])
     |> stream(:links, links, dom_id: &"link-#{&1.link.short_code}")}
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
          <a href={short_url_of(link)} class="link link-primary break-all">{short_url_of(link)}</a>
        </:col>
        <:col :let={{_id, %{link: link}}} label="Target URL">
          <span class="break-all">{link.target_url}</span>
        </:col>
        <:col :let={{_id, %{link: link}}} label="Shortened">
          {shortened_text(link.shortened_at)}
        </:col>
        <:col :let={{_id, listed}} label="Resolutions">
          <span id={"resolutions-#{listed.link.short_code}"}>{listed.resolution_count}</span>
        </:col>
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

  defp shortened_text(shortened_at), do: Calendar.strftime(shortened_at, "%Y-%m-%d %H:%M UTC")
end
