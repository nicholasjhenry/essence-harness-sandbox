# Count the resolutions of a link

**Major feature set:** Link management
**Feature set:** Resolving a short URL
**Plan position:** 3

## Milestones

| Milestone | Date reached |
|---|---|
| domain walkthrough | 2026-10-25 |
| design | 2026-10-25 |
| design inspection | 2026-10-25 |
| code | 2026-10-25 |
| code inspection | 2026-10-25 |
| integration | 2026-10-25 |

## Request

The list of the links of a user shows the number of resolutions of each link. Today the link shortener records no resolution, and the resolution appends no event. The domain walkthrough decides how a resolution is recorded, and changes that note of the domain model.

## Design

A person requests the short URL `/<short code>` of a link. The link shortener appends one `ShortUrlResolved` event, and sends the person to the target URL with `302 Found`. A short code of no link or of a deleted link gets `404 Not Found`, and no event. A logged-in user opens `/links`, and each row of the list shows the number of resolutions of its link, in the column `Resolutions`. A link with no resolution shows `0`.

The resolution now appends an event, so the slice `resolve_target_url_of_short_url` gets a command handler, by decisions 4 and 5 of the architecture. It has no `command.ex`, because the request holds only the short code of the URL, as the slice `delete_link_of_user` does. The module `Resolution` is removed, and `CommandHandler.handle/2` takes its place. The event `ShortUrlResolved` is in `lib/shortener/shared/`, because the slice of the resolution appends it and the slice of the listing reads it. The count is in the slice `list_links_of_user`, because only its page shows the count.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.ShortUrlResolved` | `to_event/1`, `from_event/1`, `type_name/0` | the event of a resolution, with `short_code`, `target_url`, `owner_email_address`, and `resolved_at`. The owner is `nil` for a link of a visitor. Tags: the tag of the short code, and the tag of the owner if the link has an owner, as `LinkShortened` has. |
| `Shortener.Features.ResolveTargetUrlOfShortUrl.ResolvedLink` | `new/1` | the `LinkShortened` of the link of a short code, or `nil` if no link has the short code or the link has a deletion. Initial state: `nil`. Handlers: `LinkShortened` gives the link of the event. `LinkDeleted` gives `nil`. Tags: the tag of the short code. It replaces `LinkTarget`, whose state was only the target URL. The decision needs the owner too, for the tag of the event. |
| `Shortener.Features.ResolveTargetUrlOfShortUrl.CommandHandler` | `handle/2` | takes the short code and `now`. It decides on `link: ResolvedLink.new(short_code)`, through `Decider.run/3`. It gives `{:ok, ShortUrlResolved.t()}`, or `{:error, :not_found}` or `{:error, :append_condition_failed}`. A value that does not have the form of a short code gives `{:error, :not_found}`, and reads nothing. |
| `Shortener.Features.ResolveTargetUrlOfShortUrl.Controller` | `show/2` | calls `handle/2` with the `short_code` parameter and `DateTime.utc_now()`. On `:ok`, it redirects to the `target_url` of the event. On each error, it answers `404 Not Found`, as it does today. |
| `Shortener.Features.ListLinksOfUser.ResolutionCounts` | `new/1` | a map from the short code of each link of the owner to the number of its resolutions. Initial state: `%{}`. Handler: `ShortUrlResolved` adds 1 to the count of its short code. Tags: the tag of the owner. |
| `Shortener.Features.ListLinksOfUser.ListedLink` | struct | one row of the list: `link`, a `LinkShortened.t()`, and `resolution_count`, a non-negative integer. |
| `Shortener.Features.ListLinksOfUser.LinkList` | `of/1` | builds one decision model with `user_links: UserLinks.new(email_address)` and `resolution_counts: ResolutionCounts.new(email_address)`. It gives a `ListedLink` for each link of `user_links`, in the same order, with the count of its short code, or 0. |
| `Shortener.Features.ListLinksOfUser.Live` | `render/1` | adds the column `Resolutions` after the column `Shortened`. The cell holds a `<span>` with the ID `resolutions-<short code>` and the count. Each other column reads the `link` of the `ListedLink`. |

### Changed modules

| Module | What changes |
|---|---|
| `Shortener.Features.ResolveTargetUrlOfShortUrl.Resolution` | removed. `CommandHandler.handle/2` takes its place. The tests of `delete_link_of_user` that call `Resolution.resolve/1` call `CommandHandler.handle/2`. |
| `Shortener.Features.ResolveTargetUrlOfShortUrl.LinkTarget` | removed. `ResolvedLink` takes its place. |
| `Shortener.Features.ListLinksOfUser.UserLinks` | no change. It reads only `LinkShortened` and `LinkDeleted`. |
| `Shortener.Projections.ShortCodeClaimed`, `ShortenTargetUrlForUser.UserLinkCount`, and `DeleteLinkOfUser.LinkOwner` | no change. Each one reads only the types of its handlers, so a `ShortUrlResolved` changes no decision of a shortening or a deletion. |

### Sequence

1. A person requests `GET /<short code>`. The router sends it to `Controller.show/2`, with no pipeline, by decision 13 of the architecture.
2. `show/2` calls `CommandHandler.handle(short_code, DateTime.utc_now())`.
3. `handle/2` checks the form of the short code with `ShortCode.valid?/1`. Then `Decider.run/3` builds the decision model. The query has one item: the types `LinkShortened` and `LinkDeleted`, with the tag of the short code.
4. `decide/1` gives `{:error, :not_found}` if `link` is `nil`. Otherwise it gives one `ShortUrlResolved` event, with the short code, the target URL, and the owner of the link, and `now`.
5. The event store appends the event with the append condition. A deletion of the link between the read and the append fails the append. The decider then reads again, and gives `{:error, :not_found}`. A second resolution of the same short URL does not fail the append, because the query holds no `ShortUrlResolved`. Two resolutions at the same time therefore both count.
6. The controller redirects to the target URL of the event, with `302 Found`.
7. A logged-in user opens `/links`. `LinkList.of/1` reads the links and the resolutions of the user in one read, and the page shows the count of each link.

### Tests

- `CommandHandler.handle/2`: a resolution of a link of a visitor gives `{:ok, %ShortUrlResolved{}}` with the target URL, no owner, and `now`, and appends one event with only the tag of the short code. A resolution of a link of a user appends one event with the tag of the short code and the tag of the owner. A short code of no link, of a deleted link, and a value of the wrong form each give `{:error, :not_found}`, and append nothing. The tests of `Resolution.resolve/1` move to `handle/2`.
- The append condition: a `LinkDeleted` of the same short code between the read and the append fails the append of a resolution, and the decider then gives `{:error, :not_found}`. A `ShortUrlResolved` of the same short code between the read and the append does not fail it. Each test builds the decision model, appends the conflicting event, and then appends with the condition of the model, as the tests of the deletion do.
- The controller: `GET /<short code>` of a link redirects to the target URL, and appends one `ShortUrlResolved`. `GET /<short code>` of no link answers 404, and appends nothing.
- `LinkList.of/1`: a link with no resolution has the count 0. A link with two resolutions has the count 2, and a second link of the same user keeps its own count. A resolution of a link of a different user changes no count of the user. The existing tests read the `link` of each `ListedLink`.
- The page: the row of a link with two resolutions shows `#resolutions-<short code>` with `2`. The row of a link with no resolution shows `0`.
- The tests of `delete_link_of_user`: after a deletion, `CommandHandler.handle/2` of the resolution gives `{:error, :not_found}`, and `LinkList.of/1` holds only the link that exists.

### Design inspection

An agent in a session other than the session of the author inspected the design, and accepted it. It applied the elixir-testing skill. It found no blocking defect. The code takes findings 1, 3, 4, and 5. It does not take finding 2:

1. `Live.mount/3` gives the stream the `dom_id` `&"link-#{&1.link.short_code}"`, because a `ListedLink` has no `short_code` of its own.
2. No test drives the second read of the decider with a stub store. The test of a deleted link shows the same result, `{:error, :not_found}`, as the design of the deletion accepted.
3. A test builds the decision model of `DeleteLinkOfUser.LinkOwner`, appends a `ShortUrlResolved` of the same short code and owner, and then appends with the condition of the model. The append succeeds, so a resolution changes no decision of a deletion.
4. The domain model records that the page reads each resolution of the links of the user.
5. The `@spec` of `handle/2` names `{:error, :append_condition_failed}`, and the controller answers `404 Not Found` for it.

### Code inspection

An agent in a session other than the session of the author inspected the code, and accepted it. It applied the testing-names-given skill. `mix test` gave 172 tests with no failure in the sprite `mcp-essence-harness-sandbox`, `mix format --check-formatted` passed, and `mix compile --warnings-as-errors --force` passed. It found no blocking defect. The code takes findings 1, 2, and 4, and `mix test` then gave 172 tests with no failure again. It does not take findings 3, 5, and 6:

1. The controller names each error, `:not_found` and `:append_condition_failed`, as the controller of the deletion does.
2. The two tests of the target URL of a link of a visitor and of a user put the condition after "given".
3. The describe block `"GET /:short_code"` of the test of the controller names a route. It is older than this feature.
4. The module attribute `@now` of the test of `LinkList` follows the aliases.
5. One test of the page uses `DateTime.utc_now()`. The time of a resolution is not shown on the page, so the test does not depend on it.
6. No test drives the second read of the decider after a deletion, as finding 2 of the design inspection accepts.

### Amendment: the count updates on the open page

The engineer requested on Sun Oct 25 2026: "update the feature so when clicking on it in list-links-for-a-user the counter updates without refreshing". A user selects a short URL on `/links`. The target URL opens in a new browser tab, and the count of the link on `/links` goes up by 1, with no reload of the page.

| Module | Operation | What changes |
|---|---|---|
| `Shortener.Shared.ShortUrlResolved` | `topic/1` | new. Takes an email address, and gives the PubSub topic of the resolutions of the links of that owner: `"short_url_resolved:"` and the tag of the owner. The topic holds no email address in clear, by decision 8 of the architecture. |
| `Shortener.Features.ResolveTargetUrlOfShortUrl.CommandHandler` | `handle/2` | after the append, broadcasts `{:short_url_resolved, ShortUrlResolved.t()}` on `Shortener.PubSub`, on the topic of the owner. A link of a visitor has no owner, so its resolution broadcasts nothing. A failed append broadcasts nothing. |
| `Shortener.Features.ListLinksOfUser.Live` | `mount/3` | subscribes to the topic of the user of the scope, if the socket is connected. |
| `Shortener.Features.ListLinksOfUser.Live` | `handle_info/2` | new. On `{:short_url_resolved, _resolved}`, reads `LinkList.of/1` again, and resets the stream `:links` with the result. The page therefore still reads the events that it shows through the same projections, by decision 9 of the architecture. The message only tells the page to read again. |
| `Shortener.Features.ListLinksOfUser.Live` | `render/1` | the anchor of the short URL gets `target="_blank"` and `rel="noopener noreferrer"`, so that `/links` stays open while the target URL opens. |

The broadcast is not a part of the decision. It occurs after the append, and the event store is still the one record of each resolution. A page that is not open misses the message, and reads each resolution when it opens.

Tests:

- `CommandHandler.handle/2`: the test subscribes to the topic of the owner, resolves a link of the owner, and receives `{:short_url_resolved, %ShortUrlResolved{}}` of the short code. A resolution of a link of a different user sends nothing to the topic. A short code of no link sends nothing.
- The page: the page of the owner is open, a resolution of a link of the owner occurs, and the row shows the new count with no reload. A resolution of a link of a different user changes no count on the page.
- The page: the anchor of each short URL has `target="_blank"` and `rel="noopener noreferrer"`.

The milestones design, design inspection, code, and code inspection were reached again for the amendment, on the same date. The dates of the Milestones table therefore do not change.

#### Design inspection of the amendment

An agent in a session other than the session of the author inspected the amendment, and accepted it. It applied the elixir-testing skill. It found no blocking defect. The code takes findings 1, 2, 4, and 6. It does not take finding 3, and it does not need to take finding 5:

1. `mount/3` subscribes before it reads `LinkList.of/1`, so that no resolution between the read and the subscription is missed.
2. The tests of the command handler subscribe before the act, and use `assert_received` and `refute_received`, because the broadcast comes from the test process.
3. The first use of PubSub can be a decision of the architecture: a name of each topic, and a message that tells a page to read again. The inspector accepted it as a note of the design. The architecture does not change in this amendment.
4. Each resolution makes each open page of the owner read the list again. One user on one computer is far below the limit of SQLite, as for the list itself.
5. No test resolves a link of a visitor for the broadcast. The tests that resolve a link of a visitor show that the clause of no owner does not fail.
6. This section states that the milestones were reached again.

#### Code inspection of the amendment

An agent in a session other than the session of the author inspected the code of the amendment, and accepted it. It applied the testing-names-given skill. It ran `mix test`, which gave 178 tests with no failure, and `mix format --check-formatted`, which passed. It found no blocking defect. The code takes findings 1 and 3, and `mix test` then gave 177 tests with no failure. It does not take finding 2:

1. The test of the page "keeps each count given a resolution of a link of a different user" is removed. It passes also if the page subscribes to the resolutions of each user, so it shows nothing. The test of the command handler shows that a resolution of a link of a different user sends nothing to the topic of the user.
2. No test shows that the resolution of a link of a visitor broadcasts nothing. A link of a visitor has no topic to subscribe to.
3. The test of the new browser tab is in the describe block of the listing, because it tests the anchor of the list, and not the update.

The formatter put the text of the anchor of the short URL on its own line. The test of the short URL in the row therefore permits white space before the end of the anchor.

---

Authored by Nicholas Henry on Sun Oct 25 2026 at 11:21:14 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 11:31:43 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 11:35:46 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 12:44:30 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 1:26:35 PM EDT
