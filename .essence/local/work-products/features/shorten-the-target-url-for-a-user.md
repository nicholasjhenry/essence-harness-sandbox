# Shorten the target URL for a user

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
| integration | |

## Design

A person types an email address and a target URL. The link shortener appends one `LinkShortened` event with the user as owner, if the user has fewer links than the link limit of the plan of the user.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Features.ShortenTargetUrlForUser.UserLinkCount` | `new/1` | the number of links of the owner. Initial state: 0. Handler: `LinkShortened` adds 1. Tags: the tag of the user. |
| `Shortener.Features.ShortenTargetUrlForUser.LinkUsage` | `of/1` | the plan and the link count of the user, for the page. It builds a decision model from `UserPlan` and `UserLinkCount`, and appends nothing. |
| `Shortener.Features.ShortenTargetUrlForUser.Command` | `changeset/2` | an embedded schema: `email_address` and `target_url`, each required. The email address has the form `name@domain`. |
| `Shortener.Features.ShortenTargetUrlForUser.CommandHandler` | `handle/3` | takes the command, the candidate short codes, and `now` |
| `Shortener.Features.ShortenTargetUrlForUser.Live` | LiveView at `/user-links` | the form, the short URL, and the number of links of the user against the link limit |

The feature uses `ShortCode`, `TargetUrl`, `LinkShortened`, `ShortCodeChoice`, `ShortCodeClaimed`, `EmailAddress`, `Plan`, and `UserPlan` from the two features before it.

### Sequence

1. `Live.handle_event("save", params)` applies `Command.changeset/2`.
2. `Live` makes three candidate short codes, and calls `CommandHandler.handle(command, candidates, DateTime.utc_now())`.
3. `CommandHandler` calls `Decider.run/3` with these projections:
   - `ShortCodeChoice.projections(candidates)`
   - `user_plan: UserPlan.new(email_address)`
   - `user_link_count: UserLinkCount.new(email_address)`
4. `decide` gives `{:error, :link_limit_reached}` if the plan has a link limit and the link count is equal to it or more. Then it takes the first free candidate, as for a visitor. It gives `{:ok, [LinkShortened.to_event(...)]}`, with the normalized email address as owner.
5. `Decider` appends under the condition. The query has these items:
   - for each candidate, the type `LinkShortened` and the tag of the short code
   - the type `PlanAssignedToUser` and the tag of the user
   - the type `LinkShortened` and the tag of the user
6. `Live` shows the short URL, and the link count against the link limit, from `LinkUsage.of/1`. It shows the error on the form if the link limit is reached.

A plan assignment of the same user after the read fails the append, because the query holds its item. A link of a different user does not fail the append, because its tags do not match.

### Tests

- The command handler: a link with the user as owner. The eleventh link of a user on the Free plan gives `{:error, :link_limit_reached}`. The eleventh link of a user on the Pro plan is made. A link of a different user does not count.
- The decision model: a plan assignment between the read and the append fails the append.
- The LiveView: a valid submission shows the short URL and the link count, and a submission at the link limit shows the error.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:08:56 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:09:14 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:15:45 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:32:28 PM EDT
