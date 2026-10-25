defmodule ShortenerWeb.LinkComponents do
  @moduledoc """
  The components that show a link, and the components of the form that
  makes a link.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias Shortener.Shared.{LinkShortened, ShortCode}

  import ShortenerWeb.CoreComponents, only: [icon: 1, input: 1]

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

  attr :field, Phoenix.HTML.FormField, required: true

  @doc """
  Shows the optional short code field of a form that makes a link. The field
  accepts no character after the length of a short code. The count reads the
  params of the form, because the value of the field is the change, with the
  spaces at the start and the end removed.
  """
  def short_code_input(assigns) do
    typed = assigns.field.form.params[Atom.to_string(assigns.field.field)] || ""

    assigns =
      assigns
      |> assign(:count, String.length(typed))
      |> assign(:limit, ShortCode.length())

    ~H"""
    <.input
      field={@field}
      type="text"
      label="Short code (optional)"
      placeholder="Summer1"
      maxlength={@limit}
    />
    <div class="flex justify-between gap-3 text-sm opacity-70 -mt-1 mb-3">
      <p id="short-code-hint">
        Seven characters from A–Z, a–z, and 0–9. Leave it empty to get a short code that the link shortener makes.
      </p>
      <p id="short-code-count" aria-live="polite" class="shrink-0 tabular-nums">{@count}/{@limit}</p>
    </div>
    """
  end

  @doc "Gives a time as `2026-10-24 21:26 UTC`."
  @spec time_text(DateTime.t()) :: String.t()
  def time_text(%DateTime{} = time), do: Calendar.strftime(time, "%Y-%m-%d %H:%M UTC")

  @spec short_url_of(LinkShortened.t()) :: String.t()
  def short_url_of(%LinkShortened{short_code: short_code}),
    do: ShortenerWeb.Endpoint.url() <> "/" <> short_code
end
