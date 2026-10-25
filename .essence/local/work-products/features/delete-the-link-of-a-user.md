# Delete the link of a user

**Major feature set:** Link management
**Feature set:** Maintaining a link
**Plan position:** 6

## Milestones

| Milestone | Date reached |
|---|---|
| domain walkthrough | 2026-10-24 |
| design | 2026-10-24 |
| design inspection | 2026-10-24 |
| code | 2026-10-24 |
| code inspection | 2026-10-24 |
| integration | |

## Design

A logged-in user opens the page `/links`, and each row of the list has a `Delete` button. The user selects the button, and confirms the deletion in the dialog of the browser. The link shortener appends one `LinkDeleted` event, and the page `/links` opens again with the message `Link deleted.` The link is not in the list. Its short URL gets `404 Not Found`, and no new link gets its short code.

The owner comes from `current_scope`, and never from the URL or a form, by decision 12 of the architecture. A short code of no link, of a deleted link, of a link of a visitor, or of a link of a different user gets the same answer: the message `You own no link with this short code.` and no event.

The slice is `lib/shortener/features/delete_link_of_user/`. It has no page, so it has `controller.ex` in place of `live.ex`, by decision 5 of the architecture. It has no `command.ex`, because the request holds only the short code of the URL, as the slice `end_login_session_of_user` holds only the session token. The event `LinkDeleted` is in `lib/shortener/shared/`, because the projections of three other slices read it.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.LinkDeleted` | `to_event/1`, `from_event/1`, `type_name/0` | the event of a deletion, with `short_code`, `owner_email_address`, and `deleted_at`. Tags: the tag of the short code, and the tag of the owner. |
| `Shortener.Features.DeleteLinkOfUser.LinkOwner` | `new/1` | the email address of the owner of the link of a short code, or `nil` if no link has the short code, the link has no owner, or the link has a deletion. Initial state: `nil`. Handlers: `LinkShortened` gives the `owner_email_address` of the event. `LinkDeleted` gives `nil`. Tags: the tag of the short code. |
| `Shortener.Features.DeleteLinkOfUser.CommandHandler` | `handle/3` | takes the scope, the short code, and `now`. It decides on `link_owner: LinkOwner.new(short_code)` and `login_session: LoginSessionUser.new(scope.session_token_hash)`, through `Decider.run/3`. It gives `{:ok, LinkDeleted.t()}`, or `{:error, :not_logged_in}`, `{:error, :not_found}`, or `{:error, :append_condition_failed}`. A value that does not have the form of a short code gives `{:error, :not_found}`, and reads nothing. |
| `Shortener.Features.DeleteLinkOfUser.Controller` | `delete/2` | calls `handle/3` with `current_scope`, the `short_code` parameter, and `DateTime.utc_now()`. On `:ok`, it puts the flash `info` `Link deleted.` On `:not_found`, it puts the flash `error` `You own no link with this short code.` On `:append_condition_failed`, it puts the flash `error` `The link was not deleted. Try again.` Each of these redirects to `/links`. On `:not_logged_in`, it puts the flash `error` `Log in to delete a link.` and redirects to `/log-in`. |
| `ShortenerWeb.Router` | — | adds `delete "/links/:short_code", DeleteLinkOfUser.Controller, :delete` to the scope that pipes through `:require_authenticated_user`, after the live session. The `:browser` pipeline checks the CSRF token. |
| `Shortener.Features.ListLinksOfUser.Live` | `render/1` | adds an action to each row: a `<.link>` with the ID `delete-<short code>`, `href={~p"/links/#{link.short_code}"}`, `method="delete"`, and `data-confirm="Delete this link? Its short URL stops working."`, with the text `Delete`. |

### Changed projections

| Module | What changes |
|---|---|
| `Shortener.Features.ShortenTargetUrlForUser.UserLinkCount` | `LinkDeleted` takes 1 from the count. Hard constraint 2 then counts only the links that exist. |
| `Shortener.Features.ResolveTargetUrlOfShortUrl.LinkTarget` | `LinkDeleted` gives `nil`, so the resolution gives `404 Not Found`. |
| `Shortener.Features.ListLinksOfUser.UserLinks` | `LinkDeleted` removes the link of the short code from the list. |
| `Shortener.Projections.ShortCodeClaimed` | no new handler. It reads only `LinkShortened`, so a short code stays claimed after its deletion. Hard constraint 1 rests on it. Its moduledoc changes to state that a deleted link keeps its short code claimed. |

The moduledocs of `UserLinkCount`, `LinkTarget`, and `UserLinks` change to state what a deletion does to each one.

### Sequence

1. The user selects `Delete` on `/links`, and confirms. The browser sends `DELETE /links/<short code>` with the CSRF token. The `:require_authenticated_user` plug checks the login session, and assigns `current_scope`.
2. `Controller.delete/2` calls `CommandHandler.handle(current_scope, short_code, now)`.
3. `handle/3` checks the form of the short code with `ShortCode.valid?/1`. Then `Decider.run/3` builds the decision model. The query has two items: the types `LinkShortened` and `LinkDeleted` with the tag of the short code, and the login session types with the tag of the login session.
4. `decide/1` gives `{:error, :not_logged_in}` if the user of the login session is not the user of the scope. It gives `{:error, :not_found}` if `link_owner` is `nil`, in a clause of its own, or if `link_owner` is not the email address of the user. The two email addresses are already normalized, because the login and the shortening normalize them. Otherwise it gives one `LinkDeleted` event.
5. The event store appends the event with the append condition. A second deletion of the same link, or a logout, between the read and the append fails the append. The decider then reads again, and the second deletion gives `{:error, :not_found}`.
6. The controller redirects to `/links`. `UserLinks` removes the link, so the list does not show it.

### Hard constraint 8 under a logout

The decision reads the login session by the hash of the session token of the scope, as the shortening for a user does. A logout in a different browser tab between the read and the append fails the append, and the decision gives `{:error, :not_logged_in}`.

### Tests

- `CommandHandler.handle/3`: a deletion of a link of the user appends one `LinkDeleted`. A short code of no link, of a link of a different user, of a link of a visitor, and of a deleted link each give `{:error, :not_found}`, and append nothing. A short code of the wrong form gives `{:error, :not_found}`. An ended login session gives `{:error, :not_logged_in}`.
- The append conditions: a `LinkDeleted` of the same short code between the read and the append fails the append of a deletion, and the decider then gives `{:error, :not_found}`. A logout of the login session between the read and the append fails the append of a deletion. A `LinkDeleted` of the same owner between the read and the append fails the append of a shortening for the user. Each test builds the decision model, appends the conflicting event, and then appends with the condition of the model, as the tests of the shortening for a user do.
- The projections: after a deletion, `Resolution.resolve/1` gives `{:error, :not_found}`. `LinkList.of/1` does not hold the link. `LinkUsage.of/1` counts one link less. A user on the Free plan with 10 links deletes one, and then shortens a target URL. A shortening that chooses the short code of a deleted link gives `{:error, :short_code_taken}`.
- The controller: `DELETE /links/<short code>` of a link of the user redirects to `/links` with `Link deleted.`, and the resolution of the short URL gives 404. A short code of a link of a different user redirects to `/links` with `You own no link with this short code.`, and the link still resolves. A visitor goes to `/log-in`.
- The page: each row of `/links` has `#delete-<short code>`, with `data-method="delete"`, `data-confirm`, and the `href` of the deletion.
- The router: the test of the first segments of the page routes still passes.

### Design inspection

An agent in a session other than the session of the author inspected the design. It applied the elixir-core skill. The first inspection rejected the design for one blocking defect: no test showed the append conditions under a second deletion, a logout, or a shortening of the same owner. The author added those tests. The second inspection accepted the design. The code takes these findings that do not block:

1. `decide/1` has a clause of its own for a `nil` owner, before each comparison. `EmailAddress.normalize/1` of `nil` raises.
2. The comparison of the owner is exact. The login normalizes each email address, so the owner of each link is already normalized. The test of an owner in upper case is removed, because it tests nothing that the code does.
3. The moduledocs of `ShortCodeClaimed`, `UserLinkCount`, `LinkTarget`, and `UserLinks` state what a deletion does to each one.
4. The `:not_logged_in` branch of the controller occurs only in a logout between the plug and the decision. The test of the command handler checks it. The test of a visitor checks the plug.

### Code inspection

An agent in a session other than the session of the author inspected the code, and accepted it. It applied the code-review and the testing-names-given skills. `mix test` gave 156 tests with no failure in the sprite `mcp-essence-harness-sandbox`, and `mix format --check-formatted` passed. It found no blocking defect. These findings do not block, and the code does not take them:

1. The code-review skill reported that the route of the deletion is outside the scope of a logged-in user. The report is false. The route is in the scope that pipes through `:require_authenticated_user`, and the test of a visitor shows the redirect to `/log-in`.
2. No test drives the second read of the decider after a failed append of a deletion. The test of a second deletion shows the same result, `{:error, :not_found}`.
3. The tests of the append conditions build each decision model with one projection, and not the query of `handle/3`. The tests of `handle/3` find a projection that `handle/3` drops.
4. The `:not_logged_in` branch of the controller has no test of the controller, as finding 4 of the design inspection accepts.

---

Authored by Nicholas Henry on Fri Oct 23 2026 at 8:55:44 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:23:40 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:55:25 PM EDT
