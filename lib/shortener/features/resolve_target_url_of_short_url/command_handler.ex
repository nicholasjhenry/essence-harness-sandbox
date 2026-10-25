defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.CommandHandler do
  @moduledoc """
  Resolves the short URL of a short code: records one resolution of the
  link, and gives the target URL to send the person to.

  A short code of no link or of a deleted link gives `{:error, :not_found}`,
  and records nothing. A value that does not have the form of a short code
  is not read.

  The decision reads only the link of the short code. A deletion of the link
  between the read and the append fails the append, and the decision runs
  again. A second resolution of the same short URL does not fail it.

  After the append, the resolution of a link of an owner is broadcast on the
  topic of the owner. A link of a visitor has no owner, and its resolution
  is not broadcast.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.ResolveTargetUrlOfShortUrl.ResolvedLink
  alias Shortener.Shared.{ShortCode, ShortUrlResolved}

  @spec handle(String.t(), DateTime.t()) ::
          {:ok, ShortUrlResolved.t()} | {:error, :not_found | :append_condition_failed}
  def handle(short_code, %DateTime{} = now) when is_binary(short_code) do
    if ShortCode.valid?(short_code),
      do: resolve(short_code, now),
      else: {:error, :not_found}
  end

  defp resolve(short_code, now) do
    with {:ok, [event]} <-
           Decider.run(
             Shortener.EventStore,
             [link: ResolvedLink.new(short_code)],
             &decide(now, &1)
           ) do
      resolved = ShortUrlResolved.from_event(event)
      broadcast(resolved)
      {:ok, resolved}
    end
  end

  defp broadcast(%ShortUrlResolved{owner_email_address: nil}), do: :ok

  defp broadcast(%ShortUrlResolved{owner_email_address: owner} = resolved),
    do:
      Phoenix.PubSub.broadcast(
        Shortener.PubSub,
        ShortUrlResolved.topic(owner),
        {:short_url_resolved, resolved}
      )

  defp decide(_now, %{link: nil}), do: {:error, :not_found}

  defp decide(now, %{link: link}) do
    fact = %ShortUrlResolved{
      short_code: link.short_code,
      target_url: link.target_url,
      owner_email_address: link.owner_email_address,
      resolved_at: now
    }

    {:ok, [ShortUrlResolved.to_event(fact)]}
  end
end
