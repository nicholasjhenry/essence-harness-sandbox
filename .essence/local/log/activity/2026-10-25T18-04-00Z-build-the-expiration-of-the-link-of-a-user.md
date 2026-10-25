# Build the expiration of the link of a user

## Activity

Build by feature, of the feature-driven-development practice, for the feature Expire the link of a user. The feature reached the code and code inspection milestones. The integration milestone waits for the request of the engineer to merge.

## Work products

- `lib/shortener/shared/link_expiration_set.ex`, `lib/shortener/shared/expiration.ex`, `lib/shortener/projections/link_of_short_code.ex` — made
- `lib/shortener/features/expire_link_of_user/command.ex`, `command_handler.ex`, `owned_link.ex`, `live.ex` — made
- `lib/shortener/features/list_links_of_user/link_expirations.ex` — made
- `lib/shortener/features/resolve_target_url_of_short_url/resolved_link.ex` — removed
- `lib/shortener/features/resolve_target_url_of_short_url/command_handler.ex`, `lib/shortener/features/list_links_of_user/listed_link.ex`, `link_list.ex`, `live.ex`, `lib/shortener_web/components/link_components.ex`, `lib/shortener_web/router.ex` — changed
- `test/shortener/shared/expiration_test.exs`, `test/shortener/features/expire_link_of_user/command_test.exs`, `command_handler_test.exs`, `live_test.exs` — made
- `test/shortener/features/resolve_target_url_of_short_url/command_handler_test.exs`, `controller_test.exs`, `test/shortener/features/list_links_of_user/live_test.exs` — changed
- `.essence/local/work-products/features/expire-the-link-of-a-user.md` — changed: the code inspection, and two milestone dates

## Agent skills

- feature-driven-development
- elixir-core, elixir-testing, and testing-names-given, by the author and by the inspector
- sprite, for a checkpoint of the sprite after the tests passed
- simplified-technical-english

## Decisions

1. The entry criterion of Build by feature holds: the feature record gives a date for the design inspection.
2. The required practice "Code a feature" is not met by an installed practice. The agent evaluated the elixir-core, elixir-testing, elixir-ecto, and testing-names-given skills. The elixir-core and elixir-testing skills, with testing-names-given for the names of the tests, are the substitute. They describe Elixir code and its ExUnit tests, which is work in Implement the System that gives the code and the unit tests of a feature. `mix test` gave 228 tests with no failure.
3. The required practice "Inspect the code of a feature" is not met by an installed practice. The agent evaluated the code-review, elixir-core, elixir-testing, and testing-names-given skills. The inspection by a new agent session with elixir-core, elixir-testing, and testing-names-given is the substitute. It is work in Test the System that gives the acceptance or the rejection of the code by an inspector who is not its author.
4. The inspector accepted the code, with no blocking finding. The code takes findings 1 to 5, and keeps finding 6 by the design. The feature record lists each finding.
5. The integration milestone is not recorded. By the integration rule of the practice, it is recorded on the work branch when the engineer requests the merge.
