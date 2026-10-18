defmodule ShortenerWeb.UserAuth do
  @moduledoc """
  The plugs and the `on_mount` callbacks of the login, by the conventions of
  `phx.gen.auth`.

  The session holds the session token. The scope of a request comes from
  the login session of that session token, in the event store. A visitor
  has the scope `nil`.
  """

  use ShortenerWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Shortener.Projections.LoginSessionUser
  alias Shortener.Shared.{Scope, Secret, User}

  @session_key "session_token"

  @spec session_key() :: String.t()
  def session_key, do: @session_key

  @doc "The scope of a session token, or `nil` if the token has no login session."
  @spec scope_for_session_token(String.t() | nil) :: Scope.t() | nil
  def scope_for_session_token(nil), do: nil

  def scope_for_session_token(session_token) when is_binary(session_token) do
    session_token_hash = Secret.hash(session_token)

    case LoginSessionUser.of(session_token_hash) do
      nil -> nil
      email_address -> Scope.for_user(%User{email_address: email_address}, session_token_hash)
    end
  end

  def fetch_current_scope_for_user(conn, _opts),
    do: assign(conn, :current_scope, scope_for_session_token(get_session(conn, @session_key)))

  def require_authenticated_user(conn, _opts) do
    if conn.assigns.current_scope do
      conn
    else
      conn
      |> put_flash(:error, "Log in to open this page.")
      |> redirect(to: ~p"/log-in")
      |> halt()
    end
  end

  @doc """
  Logs in the browser with a new session token. A new session stops a
  session that a different person fixed before the login.
  """
  def log_in_user(conn, session_token) do
    conn
    |> renew_session()
    |> put_session(@session_key, session_token)
    |> put_session(:live_socket_id, live_socket_id(Secret.hash(session_token)))
    |> redirect(to: ~p"/user-links")
  end

  @doc """
  Logs out the browser. Each open page of the login session closes its
  socket.
  """
  def log_out_user(conn) do
    if live_socket_id = get_session(conn, :live_socket_id),
      do: ShortenerWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})

    conn
    |> renew_session()
    |> put_flash(:info, "You are logged out.")
    |> redirect(to: ~p"/")
  end

  def on_mount(:mount_current_scope, _params, session, socket),
    do: {:cont, mount_current_scope(socket, session)}

  def on_mount(:require_authenticated, _params, session, socket) do
    socket = mount_current_scope(socket, session)

    if socket.assigns.current_scope do
      {:cont, socket}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, "Log in to open this page.")
       |> Phoenix.LiveView.redirect(to: ~p"/log-in")}
    end
  end

  defp mount_current_scope(socket, session) do
    Phoenix.Component.assign_new(socket, :current_scope, fn ->
      scope_for_session_token(session[@session_key])
    end)
  end

  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp live_socket_id(session_token_hash), do: "login_sessions:" <> session_token_hash
end
