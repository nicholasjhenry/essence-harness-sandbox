# Authorize the plan assignment of a user

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

Only a logged-in user reaches the plan page, and the user assigns a plan only to that user. The email address comes from `current_scope`, and the form has no email address.

### Changed concepts and operations

| Module | Operation | What changes |
|---|---|---|
| `Shortener.Features.AssignPlanToUser.Command` | `changeset/2` | the embedded schema holds only `plan` |
| `Shortener.Features.AssignPlanToUser.CommandHandler` | `handle/3` | takes the scope first: `handle(scope, command, now)`. The user of the plan assignment is `scope.user.email_address`. |
| `Shortener.Features.AssignPlanToUser.PlanOfUser` | `of/1` | the plan of the user, for the page. It builds a decision model of `UserPlan`, and appends nothing. |
| `Shortener.Features.AssignPlanToUser.Live` | LiveView at `/plans` | it shows the plan of the user on mount, from `PlanOfUser.of/1`, and a form with the plan only |
| `ShortenerWeb.Router` | | `/plans` moves to the `:require_authenticated_user` live session, in the scope that pipes through `[:browser, :require_authenticated_user]` |

### Sequence

1. A request for `/plans` with no login session redirects to `/log-in`, by the plug for an HTTP request and by the `on_mount` callback for a live navigation.
2. `Live.mount/3` reads `socket.assigns.current_scope.user`, and shows the plan of the user.
3. `Live.handle_event("save", params)` calls `CommandHandler.handle(current_scope, command, DateTime.utc_now())`. The rest of the decision is as in "Assign the plan to a user".

### Hard constraint 6 under a logout

The scope of a LiveView is set at mount. A logout in another tab does not change it. The decision therefore reads the login session again:

- The projections of the decision add `login_session: LoginSessionUser.new(scope.session_token_hash)`.
- `decide` gives `{:error, :not_logged_in}` unless the state `login_session` is `scope.user.email_address`.
- A logout between the read and the append fails the append, because the query holds the item of the login session. The decision then runs again, and gives `{:error, :not_logged_in}`.
- `Live` redirects to `/log-in` on `{:error, :not_logged_in}`.

### Tests

- The command handler: the plan assignment is for the user of the scope. After the logout of the login session of the scope, `handle/3` gives `{:error, :not_logged_in}`.
- The LiveView: a visitor is redirected to `/log-in`. A logged-in user sees the current plan, assigns Pro, and sees Pro. The form has no email address field. The tests of "Assign the plan to a user" that type an email address are rewritten for the logged-in user.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:56:28 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:56:47 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:58:21 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:11:38 PM EDT
