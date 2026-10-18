# Resolve the target URL of a short URL

**Major feature set:** Link management
**Feature set:** Resolving a short URL
**Plan position:** 3

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

A person opens a short URL. The link shortener finds the link of the short code, and answers `302 Found` with the target URL of the link. If no link has the short code, it answers `404 Not Found`. The resolution reads the event store, and appends nothing.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.ShortCode` | `valid?/1` | true if the value is seven characters from `A`–`Z`, `a`–`z`, and `0`–`9` |
| `Shortener.Features.ResolveTargetUrlOfShortUrl.LinkTarget` | `new/1` | the target URL of the link of the short code. Initial state: `nil`. Handler: `LinkShortened` gives its target URL. Tags: the tag of the short code. |
| `Shortener.Features.ResolveTargetUrlOfShortUrl.Resolution` | `resolve/1` | gives `{:ok, target_url}` or `{:error, :not_found}`. A value that is not a short code gives `{:error, :not_found}` with no read. Otherwise it builds a decision model of `LinkTarget`, and appends nothing. |
| `Shortener.Features.ResolveTargetUrlOfShortUrl.Controller` | `show/2` | the action of `GET /:short_code` |

### Sequence

1. The router sends `GET /:short_code` to `Controller.show/2`. The route is after each page route of the router, in a scope with no pipeline. `ShortCode.valid?/1` rejects each path of a page, such as `plans` or `log-in`.
2. `Controller.show/2` calls `Resolution.resolve(short_code)`.
3. `Resolution.resolve/1` checks `ShortCode.valid?/1`, and calls `DecisionModel.build(Shortener.EventStore, link_target: LinkTarget.new(short_code))`.
4. On `{:ok, target_url}`, the controller calls `redirect(conn, external: target_url)`, which answers `302 Found`.
5. On `{:error, :not_found}`, the controller calls `put_status(:not_found)`, `put_format("html")`, `put_view(html: ShortenerWeb.ErrorHTML)`, and `render(:"404")`.

### Tests

- `Resolution`: the target URL of a link of a visitor, and of a link of a user. `{:error, :not_found}` for a short code that no link has, and for a value that is not a short code.
- The controller: `GET` of the short URL of a link answers 302, with the target URL in the `location` header. `GET` of an unknown short code answers 404. `GET /` and `GET /log-in` still reach their pages.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:56:28 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:56:47 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:58:21 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:11:38 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:13:22 PM EDT
