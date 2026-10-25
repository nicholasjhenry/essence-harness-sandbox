# Build the listing of the links of a user

## Activity

Build by feature, of the feature-driven-development practice, for List the links of a user. The feature reached the code and code inspection milestones. The integration milestone waits for the merge into `main`.

The entry criterion held: the feature is Design Inspected, by its feature record.

## Work products

- `lib/shortener/features/list_links_of_user/user_links.ex` — made.
- `lib/shortener/features/list_links_of_user/link_list.ex` — made.
- `lib/shortener/features/list_links_of_user/live.ex` — made.
- `lib/shortener_web/router.ex` — the route `/links`.
- `lib/shortener_web/components/layouts.ex` — the menu item `All your links`.
- `test/shortener/features/list_links_of_user/link_list_test.exs` — made.
- `test/shortener/features/list_links_of_user/live_test.exs` — made.
- `.essence/local/work-products/features/list-the-links-of-a-user.md` — the code inspection, and two milestone dates.

## Agent skills

- feature-driven-development
- version-control
- elixir-core and testing-names-given — the substitute for the required practice "Code a feature".
- code-review, elixir-testing, and testing-names-given — used by the inspector, as the substitute for the required practice "Inspect the code of a feature".

## Decisions

- The code was written and tested in the sprite `mcp-essence-harness-sandbox`, at `/home/sprite/app`, on the branch `feat/list-the-links-of-a-user`, as commit `f77422e`. The agent copied the patch of that commit to the local work branch with `git apply`.
- The required practice "Code a feature" is not met. No installed practice has an activity in Implement the System that gives the code and the unit tests of a feature. The agent evaluated elixir-core, elixir-testing, elixir-typespec, elixir-otp, elixir-ecto, testing-names-given, code-review, and simplify. The substitute is elixir-core with testing-names-given. They describe Elixir code and the names of its ExUnit tests, which is work in Implement the System. The work gave the code and the unit tests of the feature with each test passing: `mix test` gave 137 tests with no failure, and `mix compile --force --warnings-as-errors` passed in the sprite.
- The required practice "Inspect the code of a feature" is not met. No installed practice has an activity in Test the System that gives the acceptance or the rejection of code. The agent evaluated code-review, simplify, elixir-testing, and testing-names-given. simplify changes the code, and gives no acceptance. The substitute is an agent in a new session with code-review, elixir-testing, and testing-names-given. It reviews the correctness of code and its tests, and gives an acceptance or a rejection.
- The inspector accepted the code with no blocking defect, and gave five findings that do not block. The code does not take them. The feature record lists them.
- The first test of the order of the rows failed. `LazyHTML.from_fragment/1` drops the rows of a `tbody` with no `table`. The test reads the whole page with `LazyHTML.from_document/1`. The inspection was of the code after this change.
