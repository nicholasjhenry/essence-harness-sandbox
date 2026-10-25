# Update the count of the resolutions on the open page of the links of a user

## Activity

An amendment of the feature Count the resolutions of a link, at the request of the engineer: "update the feature so when clicking on it in list-links-for-a-user the counter updates without refreshing". The activity took the amendment through Design by feature and Build by feature, up to the code inspection milestone. The work is done in the sprite `mcp-essence-harness-sandbox`, as the engineer asked: "this should be done in the sprite no?".

## Work products

- `.essence/local/work-products/features/count-the-resolutions-of-a-link.md` — changed: the section "Amendment: the count updates on the open page", with its two inspections
- `lib/shortener/shared/short_url_resolved.ex` — changed: `topic/1`
- `lib/shortener/features/resolve_target_url_of_short_url/command_handler.ex` — changed: the broadcast after the append
- `lib/shortener/features/list_links_of_user/live.ex` — changed: the subscription, `handle_info/2`, and the new browser tab of each short URL
- `test/shortener/features/resolve_target_url_of_short_url/command_handler_test.exs` — changed
- `test/shortener/features/list_links_of_user/live_test.exs` — changed

## Agent skills

- feature-driven-development
- elixir-core
- elixir-testing
- testing-names-given, applied by the author and by the code inspector
- version-control

## Decisions

- The amendment is an amendment of the feature, and not a new feature. The name of the feature does not change, so its milestone dates stay, and the amendment reaches each milestone again on the same date.
- The engineer delegated the endeavor: "completely delegated". The agent made the decisions of the amendment, with no prompt.
- The resolution broadcasts on `Shortener.PubSub`, on a topic of the owner that holds the tag of the owner, by decision 8 of the architecture. The open page reads the list again on each message, so the page still reads what it shows through its projections, by decision 9.
- The architecture does not change. Finding 3 of the design inspection proposes a decision of the architecture for the first use of PubSub. The inspector accepted a note of the design, and the request names no change of the architecture.
- A short URL on `/links` opens in a new browser tab. Otherwise the click leaves `/links`, and no open page can show the new count.
- The agent stopped the edit of a local copy at the request of the engineer. It removed the local worktree, and made each edit, each test run, and each commit of the amendment in the sprite.
- The required practices "Code a feature", "Inspect the design of a feature", and "Inspect the code of a feature" are not met, as in the build of the feature. The substitutes are the same: elixir-core and elixir-testing for the code, elixir-testing for the design inspection, and testing-names-given for the code inspection. Each one describes work in the activity space of its required practice that gives its result, as the entry `.essence/local/log/activity/2026-10-25T15-35-38Z-build-the-count-of-the-resolutions-of-a-link.md` states.
- `mix test` in the sprite gave 177 tests with no failure, and `mix format --check-formatted` passed.
