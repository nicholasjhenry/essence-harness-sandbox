# List the links of a user

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
| integration | 2026-10-24 |

## Design

A logged-in user opens the page `/links`, and sees each link that the user owns, the newest link first. Each row shows the short URL of the link, its target URL, and its time of shortening. A user who owns no link sees a message, with a link to the page that shortens a target URL. A visitor who opens `/links` goes to the login page.

The page reads the events and appends nothing. It reads each `LinkShortened` event with the tag of the user of `current_scope`. The owner comes from `current_scope`, and never from the URL or a form. A link of a visitor has no tag of a user, so it is in no list.

The slice is `lib/shortener/features/list_links_of_user/`. It reads and appends nothing that a command decides, so it has no command and no command handler, by decision 5 of the architecture. The page is in the `:require_authenticated_user` live session, by decision 12 of the architecture.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Features.ListLinksOfUser.UserLinks` | `new/1` | the links of which the user is the owner, the newest first. Initial state: `[]`. Handler: `LinkShortened` puts `LinkShortened.from_event(event)` at the start of the list. Tags: the tag of the user. |
| `Shortener.Features.ListLinksOfUser.LinkList` | `of/1` | gives the list of `LinkShortened.t()` of the email address. It builds a decision model of `UserLinks`, and appends nothing, as `LinkUsage.of/1` does. |
| `Shortener.Features.ListLinksOfUser.Live` | `mount/3`, `render/1` | the page `/links`, with the title `All your links`. It puts the links in the stream `:links`, with the DOM ID `link-<short code>`. It shows them in a table with the ID `links`. The columns are `Short URL`, `Target URL`, and `Shortened`. The short URL is a link, from `ShortenerWeb.LinkComponents.short_url_of/1`. The time is in UTC, in the form `2026-10-24 21:26 UTC`. With no link, it shows the element `#no-links` with the text `You own no links.` and a link to `/user-links`. |
| `ShortenerWeb.Router` | — | adds `live "/links", ListLinksOfUser.Live` to the `:require_authenticated_user` live session. The segment `links` has five characters, so it is not a short code. |
| `ShortenerWeb.Layouts` | `app/1` | adds the menu item `All your links`, to `/links`, for a logged-in user, after `Your links`. |

### Sequence

1. A logged-in user opens `/links`. The `:require_authenticated_user` plug and the `on_mount` callback of `UserAuth` check the login session, and assign `current_scope`.
2. `Live.mount/3` calls `LinkList.of(current_scope.user.email_address)`.
3. `LinkList.of/1` calls `DecisionModel.build(Shortener.EventStore, user_links: UserLinks.new(email_address))`. The query has one item: the type `LinkShortened` and the tag of the user. The event store gives the events in the order of their positions.
4. `UserLinks` puts each link at the start of its state, so the state holds the newest link first. `LinkList.of/1` gives the state, and does not use the append condition.
5. `Live.mount/3` puts the links in the stream `:links`, and `render/1` shows the table, or `#no-links` if the list is empty.

### Tests

- `LinkList.of/1`: the links of the owner, the newest first. No link of a different user and no link of a visitor. An empty list for an email address that owns no link. The same links for an email address in upper case.
- The page: a visitor goes to `/log-in`. A user sees a row for each link that the user owns, with the short URL and the target URL, the newest row first. A user does not see a link of a different user. A user who owns no link sees `#no-links`, with a link to `/user-links`. A link that the user shortens on `/user-links` is in the list when the user opens `/links`.
- The router: the test of the first segments of the page routes still passes with `/links`.

### Design inspection

An agent in a session other than the session of the author inspected the design, and accepted it. It found no blocking defect. The code takes these findings that do not block:

1. `LinkShortened` has no `id` field. The stream takes `dom_id: &"link-#{&1.short_code}"`.
2. `render/1` cannot test whether a stream is empty. `mount/3` sets the assign `:links_empty?`, and `render/1` shows `#no-links` from it.
3. `CoreComponents.table/1` puts its ID on the `tbody`. The tests find the rows with `#links tr`.
4. `Live` writes the time of shortening with `Calendar.strftime(shortened_at, "%Y-%m-%d %H:%M UTC")`. A page test gives a link a fixed time of shortening, and checks the text.
5. A test of `LinkList.of/1` and a test of the page each append two links with different times of shortening, and check their order.
6. The menu shows `Your links` and `All your links` side by side. The agent keeps both names. `Your links` is the title of the page that shortens a target URL, and a change to it is not in the request.
7. The describe blocks and the test names take the form of the testing-names-given skill.
8. The route `/links` is in the `:require_authenticated_user` live session, before the route `/:short_code`, as the design states.

### Code inspection

An agent in a session other than the session of the author inspected the code, and accepted it. `mix test` gave 137 tests with no failure in the sprite `mcp-essence-harness-sandbox`, and `mix format --check-formatted` passed. It found no blocking defect. These findings do not block, and the code does not take them:

1. Three test names of the page put the condition before "given", or have no "given".
2. `link_list_test.exs` and `live_test.exs` each have the same `shorten/3` function. A fixture in `test/support/` could replace them.
3. The newest link is the link of the last position, and not of the latest time of shortening. The two are the same while the link shortener sets the time of shortening at the append, and the tests do not tell them apart.
4. Both test modules run with `async: false`, as each test of the event store does.
5. A test checks the owner of a link, and its name does not state it.

---

Authored by Nicholas Henry on Fri Oct 23 2026 at 8:55:44 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:23:40 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:26:28 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:31:54 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:33:18 PM EDT
