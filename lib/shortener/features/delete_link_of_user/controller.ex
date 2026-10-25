defmodule Shortener.Features.DeleteLinkOfUser.Controller do
  @moduledoc """
  Deletes a link of the logged-in user, and goes back to the list of the
  links of the user. The owner is the user of the login session.
  """

  use ShortenerWeb, :controller

  alias Shortener.Features.DeleteLinkOfUser.CommandHandler

  def delete(conn, %{"short_code" => short_code}) do
    case CommandHandler.handle(conn.assigns.current_scope, short_code, DateTime.utc_now()) do
      {:ok, _deleted} ->
        conn |> put_flash(:info, "Link deleted.") |> redirect(to: ~p"/links")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "You own no link with this short code.")
        |> redirect(to: ~p"/links")

      {:error, :append_condition_failed} ->
        conn
        |> put_flash(:error, "The link was not deleted. Try again.")
        |> redirect(to: ~p"/links")

      {:error, :not_logged_in} ->
        conn |> put_flash(:error, "Log in to delete a link.") |> redirect(to: ~p"/log-in")
    end
  end
end
