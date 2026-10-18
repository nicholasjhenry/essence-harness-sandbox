# Assign the plan to a user

**Major feature set:** Plan management
**Feature set:** Assigning a plan
**Plan position:** 1

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

A person types an email address and selects a plan. The link shortener appends one `PlanAssignedToUser` event, if the user is not on that plan.

### New concepts and operations

The DCB event store, in `lib/shortener/dcb/`, which each feature uses:

| Module | Operation | What it does |
|---|---|---|
| `Shortener.DCB.Event` | struct | `type`, `data`, and `tags` of one event. `data` is a binary that the store does not parse. |
| `Shortener.DCB.SequencedEvent` | struct | an event and its `position` |
| `Shortener.DCB.QueryItem` | struct | `types` and `tags` |
| `Shortener.DCB.Query` | `matches?/2` | true if the event matches one item: a type of the item, if the item has types, and each tag of the item |
| `Shortener.DCB.AppendCondition` | struct | `fail_if_events_match`, a query, and `after`, a position or `nil` |
| `Shortener.DCB.EventStore` | behaviour | `read(query, opts)` gives the sequenced events that match, in position order. `append(events, condition)` gives `:ok` or `{:error, :append_condition_failed}`. |
| `Shortener.EventStore` | `read/2`, `append/2` | the SQLite implementation. `append/2` runs in one transaction that starts with `BEGIN IMMEDIATE`. It fails if an event after `after` matches `fail_if_events_match`. Then it inserts each event and its tags. |
| `Shortener.DCB.Projection` | `query_item/1`, `apply_event/3` | a pure fold with `initial_state`, one handler for each event type, and `tags` |
| `Shortener.DCB.DecisionModel` | `build/2` | reads the union of the query items of the projections, folds each projection, and gives the state with the append condition |
| `Shortener.DCB.Decider` | `run/3` | builds the decision model, calls the decide function, and appends under the condition. On `{:error, :append_condition_failed}`, it builds and decides again, up to three attempts. |

The tables of the event store, in one migration:

- `events` — `position` (integer, primary key, autoincrement), `type` (text), `data` (text), `appended_at` (UTC datetime).
- `event_tags` — `position` (references `events`), `tag` (text). The primary key is `tag` and `position`.

The concepts of this feature:

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.Plan` | `all/0`, `fetch/1`, `default/0` | the plans Free (link limit 10) and Pro (no link limit) |
| `Shortener.Shared.EmailAddress` | `normalize/1`, `tag/1` | lower case with no space at the ends. The tag is `user:` and the SHA-256 hash, in lower-case hexadecimal. |
| `Shortener.Shared.PlanAssignedToUser` | `to_event/1`, `from_event/1` | the event: `email_address`, `plan`, `assigned_at`, tagged with the tag of the user |
| `Shortener.Projections.UserPlan` | `new/1` | the name of the plan of the user. Initial state: the name of the default plan. Handler: `PlanAssignedToUser` gives its plan. Tags: the tag of the user. |
| `Shortener.Features.AssignPlanToUser.Command` | `changeset/2` | an embedded schema: `email_address` and `plan`, each required. The email address has the form `name@domain`. The plan is the name of a plan. |
| `Shortener.Features.AssignPlanToUser.CommandHandler` | `handle/2` | takes the command and `now` |
| `Shortener.Features.AssignPlanToUser.Live` | LiveView at `/plans` | the form, and the result |

### Sequence

1. `Live.handle_event("save", params)` calls `Command.changeset/2`, and applies it with `Ecto.Changeset.apply_action/2`.
2. `Live` calls `CommandHandler.handle(command, DateTime.utc_now())`.
3. `CommandHandler` calls `Decider.run(Shortener.EventStore, [user_plan: UserPlan.new(email_address)], decide)`.
4. `decide` gives `{:error, :plan_already_assigned}` if the state `user_plan` is the plan of the command. Otherwise it gives `{:ok, [PlanAssignedToUser.to_event(...)]}`.
5. `Decider` appends the event under the condition. The query is one item: the type `PlanAssignedToUser` and the tag of the user.
6. `Live` shows the plan of the user, or the error on the form.

### Tests

- The event store: a read by type, by tag, and by two items. An append that fails when an event after `after` matches. An append with no `after` that fails when an event matches. An atomic append of two events.
- The decision model: two commands that decide on the same state. The second append fails, and `Decider.run/3` decides again.
- The command handler: a first assignment, an assignment to the same plan, and an assignment of a second plan.
- The LiveView: a valid submission shows the plan, and an invalid email address shows an error.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:08:56 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:09:14 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:15:45 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:28:00 PM EDT
