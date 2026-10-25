# Expire the link of a user

**Major feature set:** Link management
**Feature set:** Maintaining a link
**Plan position:** 6

## Milestones

| Milestone | Date reached |
|---|---|
| domain walkthrough | 2026-10-25 |
| design | 2026-10-25 |
| design inspection | 2026-10-25 |
| code | 2026-10-25 |
| code inspection | 2026-10-25 |
| integration | |


## Request

The engineer requested "Expire the link of a user only", and delegated the decisions: "delegated". The domain model records the decisions of the walkthrough, in the notes of the expiration of the link of a user.

## Design

A logged-in user opens the page `/links`. Each row of the list has the column `Expires`, which shows `Never`, the time of expiration, or `Expired` and the time of expiration. Each row whose time of expiration is not past has the action `Expire`. The action opens the page `/links/<short code>/expiration`. The page shows the short URL, the target URL, and the time of expiration of the link. It has one field, `Time of expiration (UTC)`, of the type `datetime-local`, and the button `Set the expiration`. The user types a time after the time now, and selects the button. The link shortener appends one `LinkExpirationSet` event. The page `/links` opens with the message `The link expires at 2026-10-26 12:00 UTC.` From that time, the short URL gets `404 Not Found`, and the row shows `Expired`.

The owner comes from `current_scope`, and never from the URL or a form, by decision 12 of the architecture. A short code of no link, of a deleted link, of a link of a visitor, or of a link of a different user gets the same answer: the message `You own no link with this short code.` and no event. A link whose time of expiration is past gets the message `The link has expired. Its time of expiration does not change.` and no event.

The slice is `lib/shortener/features/expire_link_of_user/`, with `command.ex`, `command_handler.ex`, `owned_link.ex`, and `live.ex`, by decision 5 of the architecture. The event `LinkExpirationSet` is in `lib/shortener/shared/`, because the projections of two other slices read it. The projection of the link of a short code moves from the slice of the resolution to `lib/shortener/projections/`, because the slice of the expiration needs the same projection. Time enters the decision as data, by decision 6 of the architecture. No projection compares a time with the time now.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.LinkExpirationSet` | `to_event/1`, `from_event/1`, `type_name/0` | the event of an expiration, with `short_code`, `owner_email_address`, `expires_at`, and `set_at`. Tags: the tag of the short code, and the tag of the owner. |
| `Shortener.Shared.Expiration` | `passed?/2` | takes a time of expiration, or `nil`, and the time now. It gives `true` if the time of expiration is at or before the time now. `nil` gives `false`. |
| `Shortener.Projections.LinkOfShortCode` | `new/1` | the link of a short code and its time of expiration, as the struct `%LinkOfShortCode{link: LinkShortened.t(), expires_at: DateTime.t() \| nil}`, or `nil` if no link has the short code or the link is deleted. Initial state: `nil`. Handlers: `LinkShortened` gives the link of the event, with `expires_at: nil`. `LinkDeleted` gives `nil`. `LinkExpirationSet` puts the `expires_at` of the event, or keeps `nil`. Tags: the tag of the short code. It replaces `Shortener.Features.ResolveTargetUrlOfShortUrl.ResolvedLink`. |
| `Shortener.Features.ExpireLinkOfUser.Command` | `changeset/3` | the request of the owner, with the field `expires_at` of the type `:utc_datetime`. It takes the command, the params, and the time now. It requires `expires_at`, and gives the error `must be after the time now` if `expires_at` is not after the time now. The form shows the error before the decision. The decision checks hard constraint 10 again. |
| `Shortener.Features.ExpireLinkOfUser.CommandHandler` | `handle/4` | takes the scope, the short code, the command, and `now`. It decides on `link: LinkOfShortCode.new(short_code)` and `login_session: LoginSessionUser.new(scope.session_token_hash)`, through `Decider.run/3`. It gives `{:ok, LinkExpirationSet.t()}`, or `{:error, :not_logged_in}`, `{:error, :not_found}`, `{:error, :expired}`, `{:error, :not_after_now}`, or `{:error, :append_condition_failed}`. A value that does not have the form of a short code gives `{:error, :not_found}`, and reads nothing. |
| `Shortener.Features.ExpireLinkOfUser.OwnedLink` | `of/2` | takes the email address of the user and the short code. It gives `{:ok, LinkOfShortCode.t()}` if the user owns the link, or `{:error, :not_found}`. A value that does not have the form of a short code gives `{:error, :not_found}`, and reads nothing. It reads through `LinkOfShortCode`, and appends nothing. The page reads the link with it at the mount. |
| `Shortener.Features.ExpireLinkOfUser.Live` | `mount/3`, `render/1`, `handle_event/3` | the page of the expiration. At the mount, it reads the link with `OwnedLink.of/2`. On `{:error, :not_found}`, it puts the flash `error` `You own no link with this short code.` and navigates to `/links`. On a link whose time of expiration is past, it puts the flash `error` of `:expired`, and navigates to `/links`. The form `#expire-link-form` sends `validate` and `save`. Each event builds the changeset with `DateTime.utc_now()`. The outcomes of `save` are in the sequence. |
| `ShortenerWeb.Router` | — | adds `live "/links/:short_code/expiration", ExpireLinkOfUser.Live` to the live session `:require_authenticated_user`. |
| `Shortener.Features.ListLinksOfUser.LinkExpirations` | `new/1` | the time of expiration of each link of the owner, by short code. A link with no expiration has no entry. Handlers: `LinkExpirationSet` puts the `expires_at` of the event. Tags: the tag of the owner. |
| `ShortenerWeb.LinkComponents` | `time_text/1` | gives a time as `2026-10-24 21:26 UTC`. The list and the page of the expiration use it. |

### Changed modules

| Module | What changes |
|---|---|
| `Shortener.Features.ResolveTargetUrlOfShortUrl.CommandHandler` | decides on `link: LinkOfShortCode.new(short_code)`. `decide/2` gives `{:error, :not_found}` given `nil`, and given a link whose time of expiration is past by `Expiration.passed?/2` with `now`. Otherwise it decides as before, from the link of the state. Its moduledoc states the expiration. |
| `Shortener.Features.ListLinksOfUser.ListedLink` | gets the field `expires_at`, a `DateTime.t()` or `nil`. |
| `Shortener.Features.ListLinksOfUser.LinkList` | builds the model with `link_expirations: LinkExpirations.new(email_address)` too, and puts the `expires_at` of each link in its `ListedLink`. |
| `Shortener.Features.ListLinksOfUser.Live` | assigns `now` from `DateTime.utc_now()` at the mount and on each resolution. Each row gets the column `Expires`, with the ID `expires-<short code>` and the text `Never`, `<time>`, or `Expired <time>`, by `Expiration.passed?/2` with `now`. Each row whose time of expiration is not past gets the action `<.link>` with the ID `expire-<short code>`, `navigate={~p"/links/#{link.short_code}/expiration"}`, and the text `Expire`. The column `Shortened` uses `time_text/1`. |

`UserLinkCount`, `ShortCodeClaimed`, `UserLinks`, and `DeleteLinkOfUser.LinkOwner` do not change. A link whose time of expiration is past still exists, so it counts against the link limit, keeps its short code claimed, stays in the list, and can be deleted.

The list sets `now` only at the mount and on each resolution. A link whose time of expiration passes while the page is open keeps its time and `Expire` until the next reload. The page of the expiration and the decision then still give `:expired`, so no hard constraint breaks.

### Sequence

1. The user selects `Expire` on `/links`. The live navigation opens `/links/<short code>/expiration`. The `:require_authenticated` callback checks the login session, and assigns `current_scope`.
2. `Live.mount/3` calls `OwnedLink.of(email_address, short_code)`, and shows the short URL, the target URL, and the time of expiration, or `Never`.
3. The user types a time, and selects `Set the expiration`. `handle_event("save", ...)` builds the changeset with `now`, and applies it. An error of the field stays on the form.
4. The LiveView calls `CommandHandler.handle(current_scope, short_code, command, now)`.
5. `handle/4` checks the form of the short code with `ShortCode.valid?/1`. Then `Decider.run/3` builds the decision model. The query has two items: the types `LinkShortened`, `LinkDeleted`, and `LinkExpirationSet` with the tag of the short code, and the login session types with the tag of the login session.
6. `decide/1` gives `{:error, :not_logged_in}` if the user of the login session is not the user of the scope. It gives `{:error, :not_found}` if `link` is `nil`, in a clause of its own, or if the owner of the link is not the email address of the user. It gives `{:error, :expired}` if the time of expiration of the link is past. It gives `{:error, :not_after_now}` if the `expires_at` of the command is not after `now`, so that hard constraint 10 holds for each caller. Otherwise it gives one `LinkExpirationSet` event, with the `expires_at` of the command and `set_at: now`.
7. The event store appends the event with the append condition. A deletion or an expiration of the same link, or a logout, between the read and the append fails the append. The decider then reads again.
8. On `{:ok, set}`, the LiveView puts the flash `info` `The link expires at <time>.`, and navigates to `/links`. On `:not_after_now`, it puts the error `must be after the time now` on the field. On `:not_found` or `:expired`, it puts the flash `error` of the outcome, and navigates to `/links`. On `:append_condition_failed`, it puts the flash `error` `The link changed at the same time. Try again.`, and stays. On `:not_logged_in`, it puts the flash `error` `Log in to expire a link.`, and redirects to `/log-in`.
9. A later request for the short URL decides on `LinkOfShortCode`. From the time of expiration, the decision gives `{:error, :not_found}`, the controller answers `404 Not Found`, and no resolution is appended.

### Hard constraints under two requests

- Hard constraint 9: the decision reads the login session by the hash of the session token of the scope, as the deletion does. A logout between the read and the append fails the append, and the decision gives `{:error, :not_logged_in}`.
- Hard constraint 11: an expiration of the same link between the read and the append fails the append. The decision then reads the new time of expiration. A time of expiration that is past gives `{:error, :expired}`.
- An expiration of a link between the read and the append of a resolution fails the append of the resolution. The resolution then reads the new time of expiration.

### Tests

- `Command.changeset/3`: valid given a time after the time now, as the string `2026-10-26T12:00` that a `datetime-local` field sends. The error `must be after the time now` given the time now, and given a time before it. The error `can't be blank` given no time.
- `Expiration.passed?/2`: `false` given `nil`, `false` given a later time, `true` given the time now, and `true` given an earlier time.
- `CommandHandler.handle/4`: an expiration of a link of the user appends one `LinkExpirationSet`. A second expiration before the time of expiration appends a second one, and `OwnedLink.of/2` gives its time. A short code of no link, of a link of a different user, of a link of a visitor, and of a deleted link each give `{:error, :not_found}`, and append nothing. A short code of the wrong form gives `{:error, :not_found}`. A command whose `expires_at` is not after `now` gives `{:error, :not_after_now}`, and appends nothing. A link whose time of expiration is past gives `{:error, :expired}`, and appends nothing. An ended login session gives `{:error, :not_logged_in}`.
- `OwnedLink.of/2`: gives the link and `nil` given a link of the user with no expiration. Gives `{:error, :not_found}` given a link of a different user, and given a deleted link.
- The append conditions: a `LinkExpirationSet` of the same short code between the read and the append fails the append of an expiration. A `LinkDeleted` of the same short code between the read and the append fails the append of an expiration. A logout of the login session between the read and the append fails the append of an expiration. A `LinkExpirationSet` of the same short code between the read and the append fails the append of a resolution. Each test builds the decision model, appends the conflicting event, and then appends with the condition of the model, as the tests of the deletion do.
- A link whose time of expiration is past: it still counts against the link limit by `LinkUsage.of/1`, a shortening that chooses its short code gives `{:error, :short_code_taken}`, and `DeleteLinkOfUser.CommandHandler.handle/3` deletes it.
- The resolution: `ResolveTargetUrlOfShortUrl.CommandHandler.handle/2` gives the target URL before the time of expiration. It gives `{:error, :not_found}` at the time of expiration and after it, and appends no resolution. `GET /<short code>` of a link whose time of expiration is past answers `404 Not Found`.
- The page of the expiration: a visitor goes to `/log-in`. The page shows the short URL and `Never` given a link of the user. A submission of a later time navigates to `/links` with `The link expires at <time>.`, and the row shows the time. A submission of an earlier time shows `must be after the time now`. A short code of a link of a different user navigates to `/links` with `You own no link with this short code.` A link whose time of expiration is past navigates to `/links` with the message of `:expired`. A `LinkExpirationSet` of the same link after the mount, with a time that is past at the submission, gives the message of `:expired`.
- The list: a row shows `Never` and `#expire-<short code>` given no expiration. A row shows the time and `#expire-<short code>` given a later time of expiration. A row shows `Expired` and no `#expire-<short code>` given a time of expiration that is past.
- The router: the test of the first segments of the page routes still passes.
- The existing tests pass, with `ResolvedLink` replaced by `LinkOfShortCode` in the tests of the resolution.


### Design inspection

An agent in a session other than the session of the author inspected the design, and accepted it. It applied the elixir-core, elixir-testing, and elixir-ecto skills. It found no blocking defect. The design takes findings 1 to 5 and 7, and keeps finding 6 as a limit that the design states:

1. The decision checks hard constraint 10 again, with `{:error, :not_after_now}`, so that a caller other than the page cannot append an expiration that is not after `now`.
2. A test of the append condition under a deletion of the same link after the read.
3. Tests that a link whose time of expiration is past still counts against the link limit, keeps its short code claimed, and can be deleted.
4. The state of `LinkOfShortCode` is a struct, because its keys are fixed.
5. The read of the page is the module `OwnedLink`, as `PlanOfUser` and `LinkList` are, and it checks the form of the short code.
6. The list can show a time of expiration that passed while the page was open. The design states the limit. The page of the expiration and the decision refuse the expiration.
7. The outcome `:append_condition_failed` of the page has no test of the page. The decider retries three times, so a test of the page cannot make it occur. The flash follows the pattern of the page of the plan.


### Code inspection

An agent in a session other than the session of the author inspected the code, and accepted it. It applied the elixir-core, elixir-testing, and testing-names-given skills. `mix test` gave 228 tests with no failure in the sprite `expire-the-link-of-a-user`, `mix format --check-formatted` passed, and `mix compile --warnings-as-errors --force` passed. It found no blocking defect. The code takes findings 1 to 5, and `mix test` then gave 228 tests with no failure again. It does not take finding 6:

1. The test of a visitor on the page of the expiration states its condition after "given".
2. The two messages of the page are private functions, and not module attributes, because no pattern or guard uses them.
3. The type of `Command` permits `nil` for `expires_at`, because `%Command{}` starts with `nil`.
4. The moduledoc of the command handler of the resolution wraps its lines as the rest of the file does.
5. The test of the resolution at the time of expiration also checks that no resolution is appended.
6. The page cannot get `:not_after_now` from the decision, because the changeset and the decision get the same `now`. The branch stays, by finding 1 of the design inspection.

---

Authored by Nicholas Henry on Fri Oct 23 2026 at 8:55:44 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:23:40 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 1:53:57 PM EDT
