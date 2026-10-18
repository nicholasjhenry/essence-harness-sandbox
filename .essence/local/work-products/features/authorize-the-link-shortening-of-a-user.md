# Authorize the link shortening of a user

**Major feature set:** User management
**Feature set:** Authorizing a user
**Plan position:** 5

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

Only a logged-in user reaches the page of the links of a user, and the owner of each link is that user. The email address comes from `current_scope`, and the form has only the target URL.

### Changed concepts and operations

| Module | Operation | What changes |
|---|---|---|
| `Shortener.Features.ShortenTargetUrlForUser.Command` | `changeset/2` | the embedded schema holds only `target_url` |
| `Shortener.Features.ShortenTargetUrlForUser.CommandHandler` | `handle/4` | takes the scope first: `handle(scope, command, candidates, now)`. The owner is `scope.user.email_address`. |
| `Shortener.Features.ShortenTargetUrlForUser.Live` | LiveView at `/user-links` | it shows the link usage of the user on mount, and a form with the target URL only |
| `ShortenerWeb.Components.Layouts` | `app/1` | shows "Your links" and "Your plan" only to a logged-in user |
| `ShortenerWeb.Router` | | `/user-links` moves to the `:require_authenticated_user` live session |

### Sequence

1. A request for `/user-links` with no login session redirects to `/log-in`.
2. `Live.mount/3` shows `LinkUsage.of(current_scope.user.email_address)`.
3. `Live.handle_event("save", params)` calls `CommandHandler.handle(current_scope, command, candidates, DateTime.utc_now())`. The rest of the decision is as in "Shorten the target URL for a user". The error of `:link_limit_reached` is on the field `target_url`. The link usage after a save is `LinkUsage.of(current_scope.user.email_address)`.

### Hard constraint 7 under a logout

The scope of a LiveView is set at mount. A logout in another tab does not change it. The decision therefore reads the login session again:

- The projections of the decision add `login_session: LoginSessionUser.new(scope.session_token_hash)`.
- `decide` gives `{:error, :not_logged_in}` unless the state `login_session` is `scope.user.email_address`.
- A logout between the read and the append fails the append, because the query holds the item of the login session. The decision then runs again, and gives `{:error, :not_logged_in}`.
- `Live` redirects to `/log-in` on `{:error, :not_logged_in}`.

### Tests

- The command handler: the owner of the link is the user of the scope. The link limit of the user of the scope applies. After the logout of the login session of the scope, `handle/4` gives `{:error, :not_logged_in}`.
- The LiveView: a visitor is redirected to `/log-in`. A logged-in user sees the link usage on mount, shortens a target URL, and sees "1 of 10 links". A user at the link limit sees the error.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:56:28 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:56:47 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:58:21 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:11:38 PM EDT
