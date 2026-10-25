# Change the target URL of a link

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
| code inspection | |
| integration | |

## Request

The owner of a link changes its target URL, and the short code stays the same. Today the owner deletes the link and shortens the new target URL, and the short URL of the deleted link resolves to no target URL.

The engineer requested "let's start a separate endeavor for "Change the target URL of a link", delegated, sprite", and delegated the decisions: "delegated". The domain model records the decisions of the walkthrough, in the notes of the change of the target URL of a link.

## Design

A logged-in user opens the page `/links`. Each row whose time of expiration is not past has the action `Change target URL`. The action opens the page `/links/<short code>/target-url`. The page has the header `Change a target URL`, with the subtitle `The short URL stays the same, and goes to the new target URL.`, and the page title `Change a target URL`. It shows the short URL in `#change-target-url-short-url` and the target URL of the link in `#change-target-url-current`. It has one field, `New target URL`, of the type `url`, with the target URL of the link as its first value, and the button `Change the target URL`. The user types a new target URL, and selects the button. The link shortener appends one `LinkTargetUrlChanged` event. The page `/links` opens with the message `The short URL now goes to https://example.com/new.` From the change, the short URL sends each person to the new target URL, and the row shows the new target URL.

The owner comes from `current_scope`, and never from the URL or a form, by decision 12 of the architecture. A short code of no link, of a deleted link, of a link of a visitor, or of a link of a different user gets the same answer: the message `You own no link with this short code.` and no event. A link whose time of expiration is past gets the message `The link has expired. Its target URL does not change.` and no event. A new target URL that is the target URL of the link gets the error `must differ from the target URL of the link` on the field, and no event.

The slice is `lib/shortener/features/change_target_url_of_link/`, with `command.ex`, `command_handler.ex`, and `live.ex`, by decision 5 of the architecture. The event `LinkTargetUrlChanged` is in `lib/shortener/shared/`, because the projections of two other slices read it. The module `OwnedLink` moves from the slice of the expiration to `lib/shortener/shared/`, because the page of the change needs the same read. It is not a projection, so it goes to `shared/` and not to `projections/`. Time enters the decision as data, by decision 6 of the architecture.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.LinkTargetUrlChanged` | `to_event/1`, `from_event/1`, `type_name/0` | the event of a target URL change, with `short_code`, `owner_email_address`, `target_url`, and `changed_at`. `target_url` is the new target URL. `changed_at` is encoded in ISO 8601 in UTC, and `from_event/1` decodes it, as `LinkExpirationSet` does. Tags: the tag of the short code, and the tag of the owner. |
| `Shortener.Features.ChangeTargetUrlOfLink.Command` | `changeset/3`, `unchanged_message/0` | the request of the owner, with the field `target_url` of the type `:string`. It takes the command, the params, and the target URL of the link. It requires `target_url`, validates it with `TargetUrl.validate/2`, which removes the spaces at the start and the end, and gives the error `must differ from the target URL of the link` if the result is the target URL of the link. The form shows the errors before the decision. The decision checks hard constraint 13 again. |
| `Shortener.Features.ChangeTargetUrlOfLink.CommandHandler` | `handle/4` | takes the scope, the short code, the command, and `now`. It decides on `link: LinkOfShortCode.new(short_code)` and `login_session: LoginSessionUser.new(scope.session_token_hash)`, through `Decider.run/3`. It gives `{:ok, LinkTargetUrlChanged.t()}`, or `{:error, :not_logged_in}`, `{:error, :not_found}`, `{:error, :expired}`, `{:error, :unchanged}`, or `{:error, :append_condition_failed}`. A value that does not have the form of a short code gives `{:error, :not_found}`, and reads nothing. A `target_url` of the command that is not a binary does not match the head of `handle/4`. |
| `Shortener.Features.ChangeTargetUrlOfLink.Live` | `mount/3`, `render/1`, `handle_event/3` | the page of the change. At the mount, it reads the link with `OwnedLink.of/2`. On `{:error, :not_found}`, it puts the flash `error` `You own no link with this short code.` and navigates to `/links`. On a link whose time of expiration is past by `Expiration.passed?/2` with `DateTime.utc_now()`, it puts the flash `error` of `:expired`, and navigates to `/links`. The form `#change-target-url-form` sends `validate` and `save`. Each event builds the changeset with the target URL of the link that the mount read. The outcomes of `save` are in the sequence. |
| `ShortenerWeb.Router` | — | adds `live "/links/:short_code/target-url", ChangeTargetUrlOfLink.Live` to the live session `:require_authenticated_user`. |

### Changed modules

| Module | What changes |
|---|---|
| `Shortener.Shared.OwnedLink` | is `Shortener.Features.ExpireLinkOfUser.OwnedLink`, moved to `lib/shortener/shared/owned_link.ex`, with no change to `of/2`. Its moduledoc names the two pages. `ExpireLinkOfUser.Live` and the tests of the expiration alias the new name. |
| `Shortener.Projections.LinkOfShortCode` | gets the handler of `LinkTargetUrlChanged`. It puts the `target_url` of the event in the `link` of the state, or keeps `nil`. The resolution, the page of the expiration, and the page of the change then read the new target URL. Its moduledoc states that `link.target_url` is the current target URL, which the latest target URL change gives, and not always the target URL of the `LinkShortened` event. |
| `Shortener.Features.ListLinksOfUser.UserLinks` | gets the handler of `LinkTargetUrlChanged`. It puts the `target_url` of the event in the link of the same short code. The tag of the owner reads the event. |
| `Shortener.Features.ListLinksOfUser.Live` | each row whose time of expiration is not past gets the action `<.link>` with the ID `change-target-url-<short code>`, `navigate={~p"/links/#{link.short_code}/target-url"}`, and the text `Change target URL`, before the action of the expiration. |

The resolution does not change its code. It reads the target URL through `LinkOfShortCode`, and records the target URL of the state in each `ShortUrlResolved`. `UserLinkCount`, `ShortCodeClaimed`, `LinkExpirations`, `ResolutionCounts`, and `DeleteLinkOfUser.LinkOwner` do not change. A target URL change makes no link and removes no link, so the count against the link limit and the claim of the short code stay the same.

### Sequence

1. The user selects `Change target URL` on `/links`. The live navigation opens `/links/<short code>/target-url`. The `:require_authenticated` callback checks the login session, and assigns `current_scope`.
2. `Live.mount/3` calls `OwnedLink.of(email_address, short_code)`, and shows the short URL and the target URL. The field holds the target URL of the link.
3. The user types a new target URL, and selects `Change the target URL`. `handle_event("save", ...)` builds the changeset with the target URL of the link, and applies it. An error of the field stays on the form.
4. The LiveView calls `CommandHandler.handle(current_scope, short_code, command, DateTime.utc_now())`.
5. `handle/4` checks the form of the short code with `ShortCode.valid?/1`. Then `Decider.run/3` builds the decision model. The query has two items: the types `LinkShortened`, `LinkDeleted`, `LinkExpirationSet`, and `LinkTargetUrlChanged` with the tag of the short code, and the login session types with the tag of the login session.
6. `decide/1` gives `{:error, :not_logged_in}` if the user of the login session is not the user of the scope. It gives `{:error, :not_found}` if `link` is `nil`, in a clause of its own, or if the owner of the link is not the email address of the user. It gives `{:error, :expired}` if the time of expiration of the link is past by `Expiration.passed?/2` with `now`. It removes the spaces at the start and the end of the `target_url` of the command. It gives `{:error, :not_found}`, by `TargetUrl.valid?/1`, if the result is not a target URL, so that no event holds a value that the resolution cannot send a person to. It gives `{:error, :unchanged}` if the result is the target URL of the link, so that hard constraint 13 holds for each caller. Otherwise it gives one `LinkTargetUrlChanged` event, with the result as `target_url` and `changed_at: now`.
7. The event store appends the event with the append condition. A deletion, an expiration, or a target URL change of the same link, or a logout, between the read and the append fails the append. The decider then reads again.
8. On `{:ok, changed}`, the LiveView puts the flash `info` `The short URL now goes to <target URL>.`, and navigates to `/links`. On `:unchanged`, it puts the error `must differ from the target URL of the link` on the field. On `:not_found` or `:expired`, it puts the flash `error` of the outcome, and navigates to `/links`. On `:append_condition_failed`, it puts the flash `error` `The link changed at the same time. Try again.`, and stays. On `:not_logged_in`, it puts the flash `error` `Log in to change a target URL.`, and redirects to `/log-in`.
9. A later request for the short URL decides on `LinkOfShortCode`, which gives the new target URL. The controller answers `302 Found` with the new target URL, and the resolution records it.

### Hard constraints under two requests

- Hard constraint 12: the decision reads the login session by the hash of the session token of the scope, as the deletion and the expiration do. A logout between the read and the append fails the append, and the decision gives `{:error, :not_logged_in}`.
- Hard constraint 13: a target URL change of the same link between the read and the append fails the append. The decision then reads the new target URL, and compares the command with it.
- Hard constraint 14: an expiration of the same link between the read and the append fails the append. The decision then reads the new time of expiration.
- A target URL change between the read and the append of a resolution fails the append of the resolution. The resolution then reads the new target URL, so it never records the old target URL after the change.

### Tests

- `Command.changeset/3`: valid given a new `https` target URL. The spaces at the start and the end are removed. The error `must differ from the target URL of the link` given the target URL of the link, and given the same URL with spaces at the start and the end. The error of `TargetUrl.validate/2` given `ftp://example.com`. The error `can't be blank` given no target URL.
- `CommandHandler.handle/4`: a change of a link of the user appends one `LinkTargetUrlChanged`, and `OwnedLink.of/2` then gives the new target URL. A second change appends a second event, and the latest target URL wins. A short code of no link, of a link of a different user, of a link of a visitor, and of a deleted link each give `{:error, :not_found}`, and append nothing. A short code of the wrong form gives `{:error, :not_found}`. A command with the target URL of the link gives `{:error, :unchanged}`, and appends nothing, also given the target URL with spaces at the start and the end. A command whose target URL is `ftp://example.com` gives `{:error, :not_found}`, and appends nothing. A link whose time of expiration is past gives `{:error, :expired}`, and appends nothing. A link whose time of expiration is later is changed. An ended login session gives `{:error, :not_logged_in}`.
- The append conditions: a `LinkTargetUrlChanged`, a `LinkDeleted`, and a `LinkExpirationSet` of the same short code between the read and the append each fail the append of a change. A logout of the login session between the read and the append fails the append of a change. A `LinkTargetUrlChanged` of the same short code between the read and the append fails the append of a resolution. Each test builds the decision model, appends the conflicting event, and then appends with the condition of the model, as the tests of the expiration do.
- The resolution: `ResolveTargetUrlOfShortUrl.CommandHandler.handle/2` gives the new target URL after a change, and records it in the `ShortUrlResolved`. A resolution before the change keeps the old target URL. `GET /<short code>` after a change answers `302 Found` with the new target URL.
- A changed link: it still counts as one link against the link limit by `LinkUsage.of/1`, and a shortening that chooses its short code gives `{:error, :short_code_taken}`.
- The page of the change: a visitor goes to `/log-in`. The page shows the short URL and the target URL given a link of the user, and the field holds the target URL. A submission of a new target URL navigates to `/links` with `The short URL now goes to <target URL>.`, and the row shows the new target URL. A submission of the same target URL shows `must differ from the target URL of the link`. A submission of `ftp://example.com` shows the error of the target URL. A short code of a link of a different user navigates to `/links` with `You own no link with this short code.` A link whose time of expiration is past navigates to `/links` with the message of `:expired`. A `LinkTargetUrlChanged` of the same link after the mount, to the target URL of the submission, gives `must differ from the target URL of the link`. A logout of the login session after the mount gives the flash `Log in to change a target URL.` and a redirect to `/log-in`.
- The list: a row shows `#change-target-url-<short code>` given a link whose time of expiration is not past. A row shows no `#change-target-url-<short code>` given a time of expiration that is past. `UserLinks` gives the new target URL after a change.
- The router: the test of the first segments of the page routes still passes.
- The existing tests pass, with `ExpireLinkOfUser.OwnedLink` replaced by `Shared.OwnedLink`.

### Limits

- The form compares the new target URL with the target URL that the mount read. After a target URL change of the same link by a second request, a user who types the earlier target URL gets `must differ from the target URL of the link`, and the decision would accept it. The user reloads the page. The decision holds hard constraint 13 with the target URL that it reads.
- The outcome `:append_condition_failed` of the page has no test of the page. The decider retries three times, so a test of the page cannot make it occur. The flash follows the pattern of the page of the expiration.
- An invalid target URL in the decision gives `:not_found`, and not a reason of its own. Only a caller other than the page can send it, because the changeset refuses it first.

### Design inspection

An agent in a session other than the session of the author inspected the design, and accepted it. It applied the elixir-core, elixir-ecto, and elixir-testing skills. It found no blocking defect. The design takes findings 1 to 7, and does not take finding 8:

1. The decision removes the spaces at the start and the end of the new target URL before it compares it, so that hard constraint 13 holds for each caller.
2. The decision refuses a new target URL that is not a target URL, and `handle/4` matches only a binary target URL.
3. The page states its header, its subtitle, its page title, and the IDs of the short URL and the target URL.
4. The event states the encoding of `changed_at`.
5. The form check against the target URL of the mount is a limit that the design states.
6. The moduledoc of `LinkOfShortCode` states that `link.target_url` is the current target URL.
7. A test of the page for a logout after the mount.
8. The record of the expiration of the link of a user names `owned_link.ex` in the slice of the expiration. The record is the design of that feature as it was inspected and integrated, so it does not change. This design records the move.

---

Authored by Nicholas Henry on Sun Oct 25 2026 at 11:21:14 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 5:30:08 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 5:33:15 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 5:36:34 PM EDT
