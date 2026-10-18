defmodule Shortener.Features.RedeemLoginTokenOfUser.Controller do
  @moduledoc """
  Redeems the login token that the page of a login link posts, and logs in
  the browser.
  """

  use ShortenerWeb, :controller

  alias Shortener.Features.RedeemLoginTokenOfUser.CommandHandler
  alias Shortener.Shared.Secret
  alias ShortenerWeb.UserAuth

  def create(conn, %{"login" => %{"token" => token}}) when is_binary(token) do
    session_token = Secret.generate()

    case CommandHandler.handle(token, session_token, DateTime.utc_now()) do
      {:ok, _email_address} ->
        conn
        |> put_flash(:info, "You are logged in.")
        |> UserAuth.log_in_user(session_token)

      {:error, _reason} ->
        invalid(conn)
    end
  end

  def create(conn, _params), do: invalid(conn)

  defp invalid(conn) do
    conn
    |> put_flash(:error, "The login link is not valid, or it is expired.")
    |> redirect(to: ~p"/log-in")
  end
end
