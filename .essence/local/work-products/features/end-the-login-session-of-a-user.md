# End the login session of a user

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

A logged-in user selects "Log out". The link shortener appends one `LoginSessionEnded` event, clears the session cookie, and goes to `/`. After the logout, the session token identifies no user.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.LoginSessionEnded` | `to_event/1`, `from_event/1` | the event: `session_token_hash` and `ended_at`. The tag is the tag of the login session. |
| `Shortener.Features.EndLoginSessionOfUser.CommandHandler` | `handle/2` | takes the session token and `now`. It gives `:ok`. |
| `Shortener.Features.EndLoginSessionOfUser.Controller` | `delete/2` | the action of `DELETE /log-out` |

### Sequence

1. The layout shows a link with `method="delete"` to `/log-out`.
2. `Controller.delete/2` reads the session token from the session. If it has one, it calls `CommandHandler.handle(session_token, DateTime.utc_now())`.
3. `CommandHandler` calls `Decider.run/3` with `user: LoginSessionUser.new(Secret.hash(session_token))`. `decide` gives `{:error, :no_login_session}` if the login session has no user, and the handler then gives `:ok` with no append. Otherwise `decide` gives `{:ok, [LoginSessionEnded.to_event(...)]}`.
4. The controller calls `UserAuth.log_out_user(conn)`. It broadcasts `"disconnect"` on the `live_socket_id` of the session, so that each open page of the login session closes its socket. Then it renews and clears the session, puts the flash "You are logged out.", and redirects to `/`.

The route is in the scope that pipes through `:browser`. A person with no login session who selects "Log out" also gets a clear session.

### Tests

- The command handler: the logout of a login session makes `LoginSessionUser` give `nil`. The logout of an unknown session token appends nothing.
- The controller: `DELETE /log-out` clears the session and redirects to `/`. After it, the same session token gives no scope.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:56:28 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:56:47 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:58:21 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:11:38 PM EDT
