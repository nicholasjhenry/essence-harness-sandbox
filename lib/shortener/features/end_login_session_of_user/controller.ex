defmodule Shortener.Features.EndLoginSessionOfUser.Controller do
  @moduledoc """
  Logs out the browser: ends its login session, and clears its session.
  """

  use ShortenerWeb, :controller

  alias Shortener.Features.EndLoginSessionOfUser.CommandHandler
  alias ShortenerWeb.UserAuth

  def delete(conn, _params) do
    if session_token = get_session(conn, UserAuth.session_key()),
      do: CommandHandler.handle(session_token, DateTime.utc_now())

    UserAuth.log_out_user(conn)
  end
end
