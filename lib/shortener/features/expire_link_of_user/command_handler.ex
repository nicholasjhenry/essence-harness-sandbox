defmodule Shortener.Features.ExpireLinkOfUser.CommandHandler do
  @moduledoc """
  Sets the time of expiration of the link of a short code, if the user of
  the scope owns the link, the login session of the scope is not ended, and
  the time of expiration of the link is not past.

  A short code of no link, of a deleted link, of a link of a visitor, or of
  a link of a different user gives the same error, so that the answer does
  not say whether a different user has the short code.

  The decision reads the link of the short code and the login session of
  the scope. A deletion or an expiration of the same link, or the logout of
  the login session, between the read and the append fails the append, and
  the decision runs again.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.ExpireLinkOfUser.Command
  alias Shortener.Projections.{LinkOfShortCode, LoginSessionUser}
  alias Shortener.Shared.{Expiration, LinkExpirationSet, Scope, ShortCode}

  @spec handle(Scope.t(), String.t(), Command.t(), DateTime.t()) ::
          {:ok, LinkExpirationSet.t()}
          | {:error,
             :not_logged_in | :not_found | :expired | :not_after_now | :append_condition_failed}
  def handle(%Scope{} = scope, short_code, %Command{} = command, %DateTime{} = now)
      when is_binary(short_code) do
    if ShortCode.valid?(short_code),
      do: expire(scope, short_code, command.expires_at, now),
      else: {:error, :not_found}
  end

  defp expire(scope, short_code, expires_at, now) do
    email_address = scope.user.email_address

    projections = [
      link: LinkOfShortCode.new(short_code),
      login_session: LoginSessionUser.new(scope.session_token_hash)
    ]

    with {:ok, [event]} <-
           Decider.run(
             Shortener.EventStore,
             projections,
             &decide(email_address, expires_at, now, &1)
           ) do
      {:ok, LinkExpirationSet.from_event(event)}
    end
  end

  defp decide(email_address, _expires_at, _now, %{login_session: user})
       when user != email_address,
       do: {:error, :not_logged_in}

  defp decide(_email_address, _expires_at, _now, %{link: nil}), do: {:error, :not_found}

  defp decide(
         email_address,
         expires_at,
         now,
         %{link: %LinkOfShortCode{link: %{owner_email_address: email_address}} = link}
       ) do
    cond do
      Expiration.passed?(link.expires_at, now) -> {:error, :expired}
      not DateTime.after?(expires_at, now) -> {:error, :not_after_now}
      true -> {:ok, [expiration(link, expires_at, now)]}
    end
  end

  defp decide(_email_address, _expires_at, _now, _model), do: {:error, :not_found}

  defp expiration(%LinkOfShortCode{link: link}, expires_at, now) do
    fact = %LinkExpirationSet{
      short_code: link.short_code,
      owner_email_address: link.owner_email_address,
      expires_at: expires_at,
      set_at: now
    }

    LinkExpirationSet.to_event(fact)
  end
end
