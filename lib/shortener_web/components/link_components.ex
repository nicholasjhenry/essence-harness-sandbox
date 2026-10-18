defmodule ShortenerWeb.LinkComponents do
  @moduledoc """
  The components that show a link.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias Shortener.Shared.LinkShortened

  import ShortenerWeb.CoreComponents, only: [icon: 1]

  attr :link, LinkShortened, required: true
  slot :inner_block

  @doc "Shows the short URL of a link, with a button that copies it."
  def short_url(assigns) do
    assigns = assign(assigns, :url, short_url_of(assigns.link))

    ~H"""
    <div id="short-link" class="rounded-box border border-success/40 bg-success/10 p-4 space-y-2">
      <p class="text-sm opacity-70">Your short URL</p>
      <div class="flex items-center gap-3">
        <a id="short-url" href={@url} class="link link-primary text-lg font-semibold break-all">{@url}</a>
        <button
          id="copy-short-url"
          type="button"
          class="btn btn-sm btn-ghost"
          phx-click={JS.dispatch("shortener:copy", to: "#short-url")}
        >
          <.icon name="hero-clipboard" class="size-4" /> Copy
        </button>
      </div>
      <p class="text-sm opacity-70 break-all">
        Goes to <span id="short-link-target">{@link.target_url}</span>
      </p>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @spec short_url_of(LinkShortened.t()) :: String.t()
  def short_url_of(%LinkShortened{short_code: short_code}),
    do: ShortenerWeb.Endpoint.url() <> "/" <> short_code
end
