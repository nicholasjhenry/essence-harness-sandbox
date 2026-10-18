# Link Shortener — Architecture

The significant decisions about the organization of the link shortener. The design of each feature rests on them.

## Criteria for the selection

1. The engineer requested a web interface made with Phoenix.
2. The engineer requested that the writes use dynamic consistency boundaries, by the arc-dcb skill.
3. The link shortener runs on the computer of the engineer with no external service. The computer has no PostgreSQL server.
4. `mix test` runs each test with no setup step other than `mix setup`.
5. Each hard constraint of the domain model holds when two requests occur at the same time.

## Platforms

- macOS on the computer of the engineer, for development and tests.
- Erlang/OTP 29 and Elixir 1.20.4.
- A web browser, for the interface.

## Languages and technologies

| Technology | Version | Use |
|---|---|---|
| Elixir | 1.20.4 | all code |
| Phoenix | 1.8.15 | the web server, the router, and the layouts |
| Phoenix LiveView | the version that Phoenix 1.8.15 generates | each page |
| Ecto and `ecto_sqlite3` | the versions that Phoenix 1.8.15 generates | the tables of the event store |
| SQLite | the version that `exqlite` holds | the storage of the event store |
| Jason | the version that Phoenix 1.8.15 generates | the event data |
| Tailwind CSS and daisyUI | the versions that Phoenix 1.8.15 generates | the styles |

## Boundary of the system

- The link shortener is one Phoenix application, `shortener`, in the root of this repository.
- Its one interface is the web interface. It has no JSON API.
- It has no login, no registration, and no email delivery. A user is known by an email address that the person types.
- It holds one DCB event store. The event store holds one bounded context, the domain of the domain model.
- The resolution of a short URL to its target URL is outside this endeavor.

## Significant decisions about the organization

1. **The event store is a DCB event store.** It has two operations, `read/2` and `append/2`, as the arc-dcb skill states them. It orders each event in one sequence of positions. It holds no table other than its own. The software system has no other table.
2. **The event store keeps its events in SQLite.** The table `events` holds the position, the event type, the event data, and the time of the append. The table `event_tags` holds one row for each tag of each event. `append/2` runs in a transaction that starts with `BEGIN IMMEDIATE`, by the `default_transaction_mode: :immediate` setting of the repository. The transaction checks the append condition, and then inserts the events. Two appends therefore do not interleave.
3. **The event data is opaque to the event store.** Each event module encodes its data as JSON, and decodes it. The event store does not parse the data.
4. **Each write is a command, decided on a decision model.** A command handler composes small, pure projections with `DCB.DecisionModel.build/2`. It decides, and appends with the append condition that `build/2` gives. On `{:error, :append_condition_failed}`, it reads, decides, and appends again, up to three times.
5. **The code is organized in vertical slices.** Each feature is one slice under `lib/shortener/features/<verb_noun>/`, with `command.ex`, `command_handler.ex`, and `live.ex`. A module that a second slice needs moves to `lib/shortener/projections/`, for a projection, or to `lib/shortener/shared/`, for each other module, such as an event. The modules of the DCB event store are in `lib/shortener/dcb/`. Its SQLite implementation is `Shortener.EventStore`, in `lib/shortener/event_store.ex`.
6. **Time and randomness enter a decision as data.** The LiveView sets `now` and makes three candidate short codes. The command handler takes both as arguments. No projection reads the clock.
7. **The plans are code.** `Shortener.Shared.Plan` holds the two plans of the domain model. A plan is not an event.
8. **A tag holds no email address in clear.** The tag of a user is `user:` and the SHA-256 hash of the email address in lower case, with no space at the start or the end.
9. **A page reads the events that it shows through the same projections.** The software system has no read model table, because no page lists more than the data of one user.

## Decisions to buy, build, or reuse

- **Reuse** Phoenix, Phoenix LiveView, Ecto, `ecto_sqlite3`, and Jason.
- **Build** the DCB event store, with the structs and the functions that the arc-dcb skill states. The store is small, and its append condition is the part that the hard constraints rest on.
- **Buy** nothing.

## Key technical risks

1. **SQLite has one writer at a time.** Each append waits for the append before it. The rate of writes of one user on one computer is far below that limit. One sequence of positions is also a limit of each DCB event store.
2. **The append condition is code of this repository.** A fault in it breaks each hard constraint with no error. A test of two appends on the same decision model checks it.
3. **Two short codes can be the same.** The probability is low. The decision takes the first of the three candidate short codes that no link has.
4. **No login protects a plan assignment.** Each person who opens the page can put each email address on each plan. A login is a requirement for operation, and it is outside this endeavor.
5. **The hash of an email address can be guessed.** A person who knows an email address can compute its tag. The tag is not given outside the event store.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:10:14 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:15:26 PM EDT
