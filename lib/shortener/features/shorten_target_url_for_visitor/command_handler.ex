defmodule Shortener.Features.ShortenTargetUrlForVisitor.CommandHandler do
  @moduledoc """
  Makes a link with no owner for a target URL, with the first candidate
  short code that no link has.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.ShortenTargetUrlForVisitor.Command
  alias Shortener.Shared.{LinkShortened, ShortCodeChoice}

  @spec handle(Command.t(), [String.t(), ...], DateTime.t()) ::
          {:ok, LinkShortened.t()} | {:error, :short_code_taken | :append_condition_failed}
  def handle(%Command{} = command, [_ | _] = candidates, %DateTime{} = now) do
    projections = ShortCodeChoice.projections(candidates)

    with {:ok, [event]} <-
           Decider.run(Shortener.EventStore, projections, &decide(command, candidates, now, &1)) do
      {:ok, LinkShortened.from_event(event)}
    end
  end

  defp decide(%Command{target_url: target_url}, candidates, now, model) do
    with {:ok, short_code} <- ShortCodeChoice.first_free(candidates, model) do
      fact = %LinkShortened{short_code: short_code, target_url: target_url, shortened_at: now}
      {:ok, [LinkShortened.to_event(fact)]}
    end
  end
end
