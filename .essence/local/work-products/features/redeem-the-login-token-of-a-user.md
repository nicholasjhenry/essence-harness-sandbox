# Redeem the login token of a user

**Major feature set:** User management
**Feature set:** Logging in a user
**Plan position:** 4

## Milestones

| Milestone | Date reached |
|---|---|
| domain walkthrough | 2026-10-17 |
| design | 2026-10-17 |
| design inspection | 2026-10-17 |
| code | 2026-10-17 |
| code inspection | 2026-10-17 |
| integration | |

## Design

A person opens a login link. The page shows one button. The button posts the login token. The link shortener accepts the login token if it is known, not redeemed, and in its lifetime. It then appends one `LoginTokenRedeemed` event, which starts a login session, and puts the session token in the session cookie.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.LoginTokenRedeemed` | `to_event/1`, `from_event/1` | the event: `email_address`, `token_hash`, `session_token_hash`, and `redeemed_at`. The tags are the tag of the login token, the tag of the user, and `login_session:` and the session token hash. |
| `Shortener.Features.RedeemLoginTokenOfUser.LoginTokenStatus` | `new/1` | the state of one login token. Initial state: `:unknown`. `LoginLinkSent` gives `{:sent, email_address, sent_at}`. `LoginTokenRedeemed` gives `:redeemed`. Tags: the tag of the login token. |
| `Shortener.Features.RedeemLoginTokenOfUser.CommandHandler` | `handle/3` | takes the login token, the session token, and `now`. It gives `{:ok, email_address}` or `{:error, :invalid_token}`. |
| `Shortener.Features.RedeemLoginTokenOfUser.Live` | LiveView at `/log-in/:token` | the form with the token in a hidden field, and one button |
| `Shortener.Features.RedeemLoginTokenOfUser.Controller` | `create/2` | the action of `POST /log-in` |
| `Shortener.Projections.LoginSessionUser` | `new/1` | the email address of the user of a login session, or `nil`. Initial state: `nil`. `LoginTokenRedeemed` gives its email address. `LoginSessionEnded` gives `nil`. Tags: the tag of the login session. |
| `Shortener.Shared.User` | struct | `email_address` |
| `Shortener.Shared.Scope` | `for_user/2` | `%Scope{user: user, session_token_hash: hash}`, or `nil` for a `nil` user. A decision that needs the login session reads it again by `session_token_hash`. |
| `ShortenerWeb.UserAuth` | `fetch_current_scope_for_user/2`, `require_authenticated_user/2`, `on_mount/4`, `log_in_user/2`, `log_out_user/1` | the plugs and the callbacks of `phx.gen.auth`. A session token in the session gives a scope through `LoginSessionUser`. `log_in_user/2` renews the session, puts `"session_token"` and `"live_socket_id"` (`"login_sessions:"` and the session token hash), and redirects to `/user-links`. |

### Sequence

1. `GET /log-in/:token` mounts `Live`, which shows a form that posts the token to `/log-in`. The page does not redeem the token. A mail scanner that opens the link then does not log in.
2. `Controller.create/2` makes the session token with `Secret.generate/0`, and calls `CommandHandler.handle(token, session_token, DateTime.utc_now())`.
3. `CommandHandler` calls `Decider.run/3` with `login_token: LoginTokenStatus.new(Secret.hash(token))`.
4. `decide` gives `{:error, :invalid_token}` for `:unknown`, for `:redeemed`, and for a token whose `sent_at` is more than 900 seconds before `now`. A token at exactly 900 seconds is valid. Otherwise it gives `{:ok, [LoginTokenRedeemed.to_event(...)]}`.
5. `Decider` appends under the condition. The query is the type `LoginLinkSent` or `LoginTokenRedeemed`, and the tag of the login token. A second redemption of the same token between the read and the append fails the append. The decision then runs again, and gives `{:error, :invalid_token}`.
6. On `{:ok, _}`, the controller calls `UserAuth.log_in_user(conn, session_token)`. On `{:error, :invalid_token}`, it puts the flash "The login link is not valid, or it is expired." and redirects to `/log-in`.

The router changes:

- The `:browser` pipeline gets the plug `:fetch_current_scope_for_user`.
- In the scope that pipes through `:browser`: `live_session :current_user, on_mount: [{ShortenerWeb.UserAuth, :mount_current_scope}]`, with `/`, `/log-in`, and `/log-in/:token`. Then `post "/log-in"` and `delete "/log-out"`. A visitor needs each of them.
- In a scope that pipes through `[:browser, :require_authenticated_user]`: `live_session :require_authenticated_user, on_mount: [{ShortenerWeb.UserAuth, :require_authenticated}]`. The designs of Authorizing a user move their pages into it.
- The plug and the callback each redirect a visitor to `/log-in`, with the flash "Log in to open this page."

The layout takes `current_scope`. It shows "Log in" to a visitor. It shows the email address, "Your links", "Your plan", and "Log out" to a user. Each LiveView passes `current_scope={@current_scope}` to `Layouts.app`.

A login session has no lifetime. It ends at the logout, or when the browser loses its cookie. The final report of the endeavor names this decision.

`test/support/conn_case.ex` gets `log_in_user(conn, email_address)`. It appends a `LoginLinkSent` and a `LoginTokenRedeemed` event, and puts the session token in the test session.

### Tests

- The command handler: a sent token is redeemed once. A second redemption gives `{:error, :invalid_token}`. A token that was never sent, and a token 16 minutes after it was sent, give `{:error, :invalid_token}`. A token 14 minutes after it was sent is redeemed.
- The decision model: a redemption between the read and the append fails the append.
- The controller: a valid token puts the session token in the session and redirects to `/user-links`. A redeemed token redirects to `/log-in` with the flash.
- The LiveView: `GET /log-in/:token` shows the button, and appends nothing.
- `UserAuth`: a session token of a login session gives a scope with the user. No session token, and an unknown session token, give `nil`.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:56:28 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:56:47 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:58:21 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:11:38 PM EDT
