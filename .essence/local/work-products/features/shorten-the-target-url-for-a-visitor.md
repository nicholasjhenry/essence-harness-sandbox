# Shorten the target URL for a visitor

**Major feature set:** Link management
**Feature set:** Shortening a target URL
**Plan position:** 2

## Milestones

| Milestone | Date reached |
|---|---|
| domain walkthrough | 2026-10-17 |
| design | 2026-10-17 |
| design inspection | 2026-10-17 |
| code | 2026-10-17 |
| code inspection | 2026-10-17 |
| integration | 2026-10-17 |

## Design

A visitor types a target URL. The link shortener appends one `LinkShortened` event with a new short code, and shows the short URL.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.ShortCode` | `generate/0`, `tag/1` | seven characters from `A`–`Z`, `a`–`z`, and `0`–`9`, from `:crypto.strong_rand_bytes/1`. The tag is `short_code:` and the short code. |
| `Shortener.Shared.TargetUrl` | `validate/2` | an Ecto changeset validation: an absolute URL with the `http` or the `https` scheme and a host |
| `Shortener.Shared.LinkShortened` | `to_event/1`, `from_event/1` | the event: `short_code`, `target_url`, `owner_email_address` (`nil` for a visitor), and `shortened_at`. The tags are the tag of the short code, and the tag of the owner if the link has an owner. |
| `Shortener.Projections.ShortCodeClaimed` | `new/1` | true if a link has the short code. Initial state: false. Handler: `LinkShortened` gives true. Tags: the tag of the short code. |
| `Shortener.Shared.ShortCodeChoice` | `projections/1`, `first_free/2` | one `ShortCodeClaimed` projection for each candidate short code, and the first candidate that no link has |
| `Shortener.Features.ShortenTargetUrlForVisitor.Command` | `changeset/2` | an embedded schema: `target_url`, required and validated by `TargetUrl.validate/2` |
| `Shortener.Features.ShortenTargetUrlForVisitor.CommandHandler` | `handle/3` | takes the command, the candidate short codes, and `now` |
| `Shortener.Features.ShortenTargetUrlForVisitor.Live` | LiveView at `/` | the form, and the short URL |

### Sequence

1. `Live.handle_event("save", params)` applies `Command.changeset/2`.
2. `Live` makes three candidate short codes with `ShortCode.generate/0`, and calls `CommandHandler.handle(command, candidates, DateTime.utc_now())`. The randomness and the time enter the decision as data.
3. `CommandHandler` calls `Decider.run/3` with the projections of `ShortCodeChoice.projections(candidates)`.
4. `decide` takes the first candidate that no link has. It gives `{:error, :short_code_taken}` if each candidate is taken. Otherwise it gives `{:ok, [LinkShortened.to_event(...)]}`, with no owner.
5. `Decider` appends under the condition. The query has one item for each candidate: the type `LinkShortened` and the tag of the short code.
6. `Live` shows the short URL: the URL of the endpoint, `/`, and the short code.

### Tests

- The command handler: a link with the first candidate. A link with the second candidate if a link has the first. `{:error, :short_code_taken}` if each candidate is taken.
- The command: a URL with no scheme, an `ftp` URL, and a URL with no host are not valid.
- The LiveView: a valid submission shows the short URL, and an invalid URL shows an error.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:08:56 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:09:14 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:15:45 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:32:28 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:37:14 PM EDT
