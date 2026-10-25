# Build the count of the characters of a short code

## Activity

Build by feature, of the feature-driven-development practice, for the feature Count the characters of a short code. The feature reached the milestones code and code inspection. The integration milestone waits for the request of the engineer to merge the work branch.

## Work products

- `lib/shortener/shared/short_code.ex` — changed: `length/0`
- `lib/shortener_web/components/link_components.ex` — changed: `short_code_input/1`, and the moduledoc
- `lib/shortener/features/shorten_target_url_for_visitor/live.ex` — changed
- `lib/shortener/features/shorten_target_url_for_user/live.ex` — changed
- `test/shortener/shared/short_code_test.exs` — changed
- `test/shortener/features/shorten_target_url_for_visitor/live_test.exs` — changed
- `test/shortener/features/shorten_target_url_for_user/live_test.exs` — changed
- `.essence/local/work-products/features/count-the-characters-of-a-short-code.md` — changed: the milestone dates, and the Code inspection section

## Agent skills

- feature-driven-development
- elixir-core
- elixir-testing
- testing-names-given
- version-control
- simplified-technical-english

## Decisions

1. The entry criterion Feature Design Inspected holds: the feature record holds the date of the design inspection, from commit `a778fe8`.
2. The required practice "Code a feature" is not met by an installed practice. The skills evaluated: elixir-core, elixir-testing, simplify. The substitute is elixir-core with elixir-testing. Together they describe the code and the unit tests of Elixir work in the activity space Implement the System, and the work gave the code and the tests from the design, with each test passing.
3. The required practice "Inspect the code of a feature" is not met by an installed practice. The skills evaluated: code-review, testing-names-given, elixir-testing. The substitute is an inspection by a new agent session that did not write the code, with the testing-names-given, elixir-testing, and elixir-core skills. It gives the acceptance or the rejection of the code, by an inspector who is not its author, in the activity space Test the System. code-review was not selected, because it reports findings and gives no acceptance.
4. The inspector accepted the code. The code takes findings 1 and 5. The reasons for the findings that it does not take are in the Code inspection section of the feature record.
5. `mix test` gave 185 tests with no failure after the last change of the code. `mix format --check-formatted` and `mix compile --warnings-as-errors --force` passed.
6. The integration milestone is not recorded. It waits for the request of the engineer to merge, by the `the-integration-milestone-is-recorded-on-the-work-branch-of-its-feature` rule and R6 of the `a-reviewer-overrides-entry-criteria-and-delegated-work-ends-in-a-pull-request` rule.
7. The inspection by an agent in place of the engineer rests on the delegation: "delegated". No entry criterion was overridden.
