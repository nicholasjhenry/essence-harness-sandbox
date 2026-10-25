defmodule Shortener.Features.ChangeTargetUrlOfLink.CommandHandler do
  @moduledoc """
  Replaces the target URL of the link of a short code with a new target URL,
  if the user of the scope owns the link, the login session of the scope is
  not ended, the time of expiration of the link is not past, and the new
  target URL is not the target URL of the link.

  A short code of no link, of a deleted link, of a link of a visitor, or of
  a link of a different user gives the same error, so that the answer does
  not say whether a different user has the short code.

  The decision reads the link of the short code and the login session of
  the scope. A deletion, an expiration, or a target URL change of the same
  link, or the logout of the login session, between the read and the append
  fails the append, and the decision runs again.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.ChangeTargetUrlOfLink.Command
  alias Shortener.Projections.{LinkOfShortCode, LoginSessionUser}
  alias Shortener.Shared.{Expiration, LinkTargetUrlChanged, Scope, ShortCode, TargetUrl}

  @spec handle(Scope.t(), String.t(), Command.t(), DateTime.t()) ::
          {:ok, LinkTargetUrlChanged.t()}
          | {:error,
             :not_logged_in | :not_found | :expired | :unchanged | :append_condition_failed}
  def handle(%Scope{} = scope, short_code, %Command{target_url: target_url}, %DateTime{} = now)
      when is_binary(short_code) and is_binary(target_url) do
    if ShortCode.valid?(short_code),
      do: change(scope, short_code, String.trim(target_url), now),
      else: {:error, :not_found}
  end

  defp change(scope, short_code, target_url, now) do
    email_address = scope.user.email_address

    projections = [
      link: LinkOfShortCode.new(short_code),
      login_session: LoginSessionUser.new(scope.session_token_hash)
    ]

    with {:ok, [event]} <-
           Decider.run(
             Shortener.EventStore,
             projections,
             &decide(email_address, target_url, now, &1)
           ) do
      {:ok, LinkTargetUrlChanged.from_event(event)}
    end
  end

  defp decide(email_address, _target_url, _now, %{login_session: user})
       when user != email_address,
       do: {:error, :not_logged_in}

  defp decide(_email_address, _target_url, _now, %{link: nil}), do: {:error, :not_found}

  defp decide(
         email_address,
         target_url,
         now,
         %{link: %LinkOfShortCode{link: %{owner_email_address: email_address}} = link}
       ) do
    cond do
      Expiration.passed?(link.expires_at, now) -> {:error, :expired}
      not TargetUrl.valid?(target_url) -> {:error, :not_found}
      target_url == link.link.target_url -> {:error, :unchanged}
      true -> {:ok, [target_url_change(link, target_url, now)]}
    end
  end

  defp decide(_email_address, _target_url, _now, _model), do: {:error, :not_found}

  defp target_url_change(%LinkOfShortCode{link: link}, target_url, now) do
    fact = %LinkTargetUrlChanged{
      short_code: link.short_code,
      owner_email_address: link.owner_email_address,
      target_url: target_url,
      changed_at: now
    }

    LinkTargetUrlChanged.to_event(fact)
  end
end
