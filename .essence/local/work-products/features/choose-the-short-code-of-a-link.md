# Choose the short code of a link

**Major feature set:** Link management
**Feature set:** Shortening a target URL
**Plan position:** 2

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

A person who shortens a target URL can type a short code in a second field of the form. The field is optional. A person who types no short code gets a short code that the link shortener makes, as before. A person who types a short code gets a link with that short code, or an error on the field. The visitor page at `/` and the user page at `/user-links` each get the field.

A chosen short code is the one candidate of the decision. The command handlers of the two shortening slices do not change. `ShortCodeChoice.first_free/2` gives `{:error, :short_code_taken}` when a link has the one candidate, and the decision appends nothing. The append condition of the decision holds the tag of the chosen short code, so that two requests for the same chosen short code make at most one link.

The resolution does not change. A chosen short code has the form that `ShortCode.valid?/1` accepts, so `GET /<chosen short code>` resolves it.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.ShortCode` | `validate/2` | validates the optional short code field of a changeset. It removes each space at the start and the end. A field that is then empty is no change. A value that `valid?/1` rejects gets the error `must be seven letters or digits`. |
| `Shortener.Shared.ShortCodeChoice` | `candidates/1` | the candidate short codes of a decision. `nil` gives three short codes from `ShortCode.generate/0`. A chosen short code gives a list of that one short code. The number three moves here from the two LiveViews. |
| `Shortener.Features.ShortenTargetUrlForVisitor.Command` | `changeset/2` | casts the new optional field `short_code`, and calls `ShortCode.validate(:short_code)`. |
| `Shortener.Features.ShortenTargetUrlForUser.Command` | `changeset/2` | the same as the visitor command. |
| `Shortener.Features.ShortenTargetUrlForVisitor.Live` | `render/1`, `handle_event/3` | shows the field `Short code (optional)`. On `save`, it calls `ShortCodeChoice.candidates(command.short_code)`. On `{:error, :short_code_taken}` with a chosen short code, it adds the error `is the short code of a link. Choose a different short code.` to the field. With no chosen short code, it shows the flash as before. |
| `Shortener.Features.ShortenTargetUrlForUser.Live` | `render/1`, `handle_event/3` | the same as the visitor page. The link limit is checked before the short code, as before. |

### Sequence

1. The person types a target URL and, optionally, a short code, and submits the form.
2. The LiveView builds the command with `Command.changeset/2`, and applies it. A short code that is not seven letters or digits stops the submission with an error on the field.
3. The LiveView calls `ShortCodeChoice.candidates(command.short_code)`, and then the command handler of its slice with the candidates and `DateTime.utc_now()`.
4. The command handler builds the decision model with one `ShortCodeClaimed` projection for each candidate, as before, and decides. For a chosen short code, the one projection is of that short code.
5. On `{:ok, link}`, the LiveView shows the short URL, and clears the form.
6. On `{:error, :short_code_taken}`, the LiveView shows the error on the field if the person chose the short code, or the flash if the link shortener made it.

### Tests

- `ShortCode.validate/2`: a valid short code is a change, with each space at the start and the end removed. An empty field and a field of spaces are no change. A value of six characters, of eight characters, or with a dash gets the error.
- `ShortCodeChoice.candidates/1`: `nil` gives three short codes that `valid?/1` accepts. `"Summer1"` gives `["Summer1"]`.
- Each command: the field `short_code` is cast and validated.
- The visitor page: a chosen short code gives a short URL that ends with `/Summer1`, and `GET /Summer1` then answers 302 with the target URL. A second submission of `Summer1` shows the error on the field, and no short URL. A short code of three characters shows the form error. A submission with no short code still gives a short code of seven characters.
- The user page: a chosen short code gives a short URL that ends with `/Summer1`, and the link usage counts it. A short code that a link has shows the error on the field, and the link usage does not change.

### Design inspection

An agent in a session other than the session of the author inspected the design, and accepted it. It found no blocking defect. The code takes these findings that do not block:

1. The `else` clause of the `save` event cannot see `command`. It reads the chosen short code from the changeset with `Ecto.Changeset.get_change/2`.
2. The error on the field needs `action: :insert` on the form, as the error of the link limit has.
3. `{:error, :append_condition_failed}` with a chosen short code shows a flash that does not say that the link shortener made the short code.
4. A test of the router checks that no path of a page has the form of a short code.
5. The tests also cover a handler with one chosen candidate that a link has, a user at the link limit who chooses a short code that a link has, `Summer1` and `summer1` as two short codes, and the removal of the spaces of a chosen short code on a page.
6. The documentation of `ShortCode` and `ShortCodeChoice`, and the type of each command, state the chosen short code.
7. The error and the hint of the field say that a short code holds only `A`–`Z`, `a`–`z`, and `0`–`9`.

### Code inspection

An agent in a session other than the session of the author inspected the code, and accepted it. `mix test` gave 125 tests with no failure, and `mix format --check-formatted` passed. It found no blocking defect. These findings do not block, and the code does not take them:

1. No test reaches the flash "The link shortener could not save the link. Try again." A test would need an append that fails three times.
2. No test sends a short code that is not valid to the command of the user. The two commands have the same changeset.
3. `test/shortener/shared/short_code_test.exs` has its own `errors_on/1`, and `Shortener.DataCase.errors_on/1` could replace it.
4. Two test names have no condition after "given".
5. The error of a short code that a link has ends with no full stop, as each Ecto error does.

---

Authored by Nicholas Henry on Fri Oct 23 2026 at 8:55:44 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 7:57:15 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 7:59:11 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 8:39:25 PM EDT
