# Code the change of the target URL of a link

## Activity

Build by feature, of the feature-driven-development practice: the code milestone of the feature Change the target URL of a link.

## Work products

- `lib/shortener/features/change_target_url_of_link/command.ex`, `command_handler.ex`, `live.ex` — made. The slice of the feature.
- `lib/shortener/shared/link_target_url_changed.ex` — made. The event of a target URL change.
- `lib/shortener/shared/owned_link.ex` — moved from `lib/shortener/features/expire_link_of_user/owned_link.ex`, and renamed `Shortener.Shared.OwnedLink`.
- `lib/shortener/projections/link_of_short_code.ex`, `lib/shortener/features/list_links_of_user/user_links.ex` — changed. Each reads `LinkTargetUrlChanged`.
- `lib/shortener/features/list_links_of_user/live.ex` — changed. The action `Change target URL`.
- `lib/shortener/features/expire_link_of_user/live.ex` — changed. It aliases `Shortener.Shared.OwnedLink`.
- `lib/shortener_web/router.ex` — changed. The route `/links/:short_code/target-url`.
- `test/shortener/features/change_target_url_of_link/command_test.exs`, `command_handler_test.exs`, `live_test.exs` — made.
- `test/shortener/features/expire_link_of_user/command_handler_test.exs`, `test/shortener/features/list_links_of_user/link_list_test.exs`, `test/shortener/features/list_links_of_user/live_test.exs`, `test/shortener/features/resolve_target_url_of_short_url/controller_test.exs` — changed.
- `.essence/local/work-products/features/change-the-target-url-of-a-link.md` — changed. It records the date of the code milestone.

## Agent skills

- feature-driven-development — build by feature.
- elixir-core, elixir-ecto, elixir-testing, testing-names-given — the substitute for the required practice Code a feature.
- version-control — the commit.

## Decisions

1. The entry criterion of Build by feature holds. The feature is Design Inspected, by the date of the design inspection milestone in its feature record.
2. The required practice "Code a feature" is not met. No installed practice has an activity in Implement the System that gives the code and the unit tests of a feature. The agent evaluated the elixir-core, elixir-ecto, elixir-testing, elixir-otp, elixir-typespec, testing-names-given, code-review, and simplify skills. The substitute is the elixir-core, elixir-ecto, elixir-testing, and testing-names-given skills. They describe Elixir code, Ecto changesets, ExUnit tests, and the names of the tests, which is work in Implement the System that gives the code and the unit tests of a feature. The work gave its result: `mix test` gave 269 tests with no failure.
3. The test of a logout after the mount reads the flash with `assert_redirect/1`, because a redirect out of the LiveView signs its flash.
4. `mix format --check-formatted` and `mix compile --warnings-as-errors --force` pass.
