defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.Controller do
  @moduledoc """
  Sends a person from a short URL to the target URL of its link, with
  `302 Found`, and records the resolution. A short URL with no link gives
  `404 Not Found`.
  """

  use ShortenerWeb, :controller

  alias Shortener.Features.ResolveTargetUrlOfShortUrl.CommandHandler

  def show(conn, %{"short_code" => short_code}) do
    case CommandHandler.handle(short_code, DateTime.utc_now()) do
      {:ok, resolved} ->
        redirect(conn, external: resolved.target_url)

      {:error, reason} when reason in [:not_found, :append_condition_failed] ->
        conn
        |> put_status(:not_found)
        |> put_format("html")
        |> put_view(html: ShortenerWeb.ErrorHTML)
        |> render(:"404")
    end
  end
end
