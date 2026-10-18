defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.Controller do
  @moduledoc """
  Sends a person from a short URL to the target URL of its link, with
  `302 Found`. A short URL with no link gives `404 Not Found`.
  """

  use ShortenerWeb, :controller

  alias Shortener.Features.ResolveTargetUrlOfShortUrl.Resolution

  def show(conn, %{"short_code" => short_code}) do
    case Resolution.resolve(short_code) do
      {:ok, target_url} ->
        redirect(conn, external: target_url)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> put_format("html")
        |> put_view(html: ShortenerWeb.ErrorHTML)
        |> render(:"404")
    end
  end
end
