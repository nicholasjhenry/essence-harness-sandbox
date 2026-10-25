# Build the check of the availability of a short code

## Activity

Build by feature, of the feature-driven-development practice, for the feature Check the availability of a short code. The feature reached the code and code inspection milestones. The integration milestone waits for the request of the engineer to merge.

The entry criterion held. The feature is Design Inspected, by the dates of `.essence/local/work-products/features/check-the-availability-of-a-short-code.md`.

## Work products

- `lib/shortener/shared/short_code_availability.ex` — made.
- `lib/shortener_web/components/link_components.ex` — changed. `short_code_input/1` shows the availability.
- `lib/shortener/features/shorten_target_url_for_visitor/live.ex` — changed.
- `lib/shortener/features/shorten_target_url_for_user/live.ex` — changed.
- `test/shortener/shared/short_code_availability_test.exs` — made.
- `test/shortener/features/shorten_target_url_for_visitor/live_test.exs` — changed.
- `test/shortener/features/shorten_target_url_for_user/live_test.exs` — changed.
- `.essence/local/work-products/features/check-the-availability-of-a-short-code.md` — changed. It holds the code inspection, and the dates of two milestones.

## Agent skills

- feature-driven-development
- version-control
- elixir-core, elixir-testing, and testing-names-given
- simplified-technical-english

## Decisions

1. The required practice "Code a feature" is not met. No installed practice has an activity in Implement the System that gives the code and the unit tests of a feature. The agent evaluated the elixir-core, elixir-ecto, elixir-testing, testing-names-given, and simplify skills. The substitute is elixir-core with elixir-testing and testing-names-given. They describe Elixir code and its ExUnit tests, which is work in Implement the System that gives the code and the unit tests of a feature. elixir-ecto describes schemas and queries, which the feature does not change. simplify cleans code, and does not write it. The work ended with each unit test passing: `mix test` gave 244 tests with no failure.
2. The required practice "Inspect the code of a feature" is not met. No installed practice has an activity in Test the System that gives the acceptance or the rejection of code. The agent evaluated the code-review, simplify, elixir-core, elixir-testing, and testing-names-given skills. The substitute is an agent in a new session that applies elixir-core, elixir-testing, and testing-names-given, and runs the tests. The inspector is not the author, and its verdict gives the acceptance or the rejection of the code. code-review reports defects, and gives no verdict.
3. The inspector accepted the code, with no blocking finding. The code takes none of its five findings. The feature record gives each finding and the reason.
4. The test of a page reads the text of `#short-code-availability` with the tags removed, because the project has no HTML parser as a test dependency.
5. The work branch is pushed, and its pull request is opened, because the work of the delegation on the branch is complete. The integration milestone waits for the request of the engineer to merge, by the `the-integration-milestone-is-recorded-on-the-work-branch-of-its-feature` rule.
