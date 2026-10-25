defmodule Shortener.Features.DeleteLinkOfUser.CommandHandler do
  @moduledoc """
  Deletes the link of a short code, if the user of the scope owns the link
  and the login session of the scope is not ended.

  A short code of no link, of a deleted link, of a link of a visitor, or of
  a link of a different user gives the same error, so that the answer does
  not say whether a different user has the short code.

  The decision reads the link of the short code and the login session of
  the scope. A deletion of the same link, or the logout of the login
  session, between the read and the append fails the append, and the
  decision runs again.
  """

  alias Shortener.DCB.Decider
  alias Shortener.Features.DeleteLinkOfUser.LinkOwner
  alias Shortener.Projections.LoginSessionUser
  alias Shortener.Shared.{LinkDeleted, Scope, ShortCode}

  @spec handle(Scope.t(), String.t(), DateTime.t()) ::
          {:ok, LinkDeleted.t()}
          | {:error, :not_logged_in | :not_found | :append_condition_failed}
  def handle(%Scope{} = scope, short_code, %DateTime{} = now) when is_binary(short_code) do
    if ShortCode.valid?(short_code),
      do: delete(scope, short_code, now),
      else: {:error, :not_found}
  end

  defp delete(scope, short_code, now) do
    email_address = scope.user.email_address

    projections = [
      link_owner: LinkOwner.new(short_code),
      login_session: LoginSessionUser.new(scope.session_token_hash)
    ]

    with {:ok, [event]} <-
           Decider.run(
             Shortener.EventStore,
             projections,
             &decide(email_address, short_code, now, &1)
           ) do
      {:ok, LinkDeleted.from_event(event)}
    end
  end

  defp decide(email_address, _short_code, _now, %{login_session: user})
       when user != email_address,
       do: {:error, :not_logged_in}

  defp decide(_email_address, _short_code, _now, %{link_owner: nil}), do: {:error, :not_found}

  defp decide(email_address, short_code, now, %{link_owner: email_address}) do
    fact = %LinkDeleted{
      short_code: short_code,
      owner_email_address: email_address,
      deleted_at: now
    }

    {:ok, [LinkDeleted.to_event(fact)]}
  end

  defp decide(_email_address, _short_code, _now, _model), do: {:error, :not_found}
end
