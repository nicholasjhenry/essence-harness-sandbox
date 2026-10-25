# Inspect the code of the change of the target URL of a link

## Activity

Build by feature, of the feature-driven-development practice: the code inspection milestone of the feature Change the target URL of a link.

## Work products

- `test/shortener/features/change_target_url_of_link/live_test.exs` — changed. Finding 1 of the code inspection.
- `test/shortener/features/change_target_url_of_link/command_handler_test.exs` — changed. Finding 2 of the code inspection.
- `.essence/local/work-products/features/change-the-target-url-of-a-link.md` — changed. It records the result of the code inspection and the date of the code inspection milestone.

## Agent skills

- feature-driven-development — build by feature.
- elixir-core, elixir-testing, testing-names-given — applied by the inspector, as the substitute for the required practice Inspect the code of a feature.
- version-control — the commit.

## Decisions

1. The required practice "Inspect the code of a feature" is not met. No installed practice has an activity in Test the System that gives the acceptance or the rejection of the code of a feature. The agent evaluated the elixir-core, elixir-ecto, elixir-testing, elixir-otp, elixir-typespec, testing-names-given, code-review, and simplify skills. The substitute is an inspector agent, in a session other than the session of the author, that applies the elixir-core, elixir-testing, and testing-names-given skills. These skills describe the Elixir code, the ExUnit tests, and the names of the tests of the feature. The inspector reads the code against the design, runs the tests, and gives an acceptance or a rejection, which is the result of the required practice.
2. The inspector accepted the code, with four findings that do not block. The code takes findings 1 and 2. It does not take finding 3, because no decision of a shortening checks the length of a target URL, and the design does not state it. Finding 4 is a limit that the design states.
3. `mix test` gave 269 tests with no failure after the findings. `mix format --check-formatted` and `mix compile --warnings-as-errors --force` pass.
4. The integration milestone waits for the request of the engineer to merge, by the rule of the integration milestone. The delegation does not give the merge to a reviewer.
