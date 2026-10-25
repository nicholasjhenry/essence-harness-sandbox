# Apply the elixir skills to the choice of the short code

## Activity

A correction of the code of the feature Choose the short code of a link, against the full rules of the elixir skills. The engineer approved it in the session on Sat Oct 24 2026: "approved". The proposal was to read the four skills in full, to check the merged code against them, and to correct each deviation in a commit on a work branch.

## Work products

- `lib/shortener/shared/short_code.ex` — changed. `validate/2` uses `validate_format/3`, and `valid?/1` uses the same regex.
- `lib/shortener/features/shorten_target_url_for_visitor/command.ex` and `lib/shortener/features/shorten_target_url_for_user/command.ex` — changed. Each `@type t` has a `@typedoc` by the template of the fields, and `target_url` can be `nil`.
- `test/shortener/shared/short_code_test.exs` — changed. It uses `Shortener.DataCase.errors_on/1`.
- `test/shortener/features/shorten_target_url_for_visitor/live_test.exs` — changed. One test name states its condition.

## Agent skills

- elixir-core, elixir-ecto, elixir-testing, elixir-typespec, and testing-names-given, each read in full with its vocabulary
- version-control

## Decisions

- In `.essence/local/log/activity/2026-10-25T00-39-25Z-code-the-choice-of-the-short-code-of-a-link.md`, the agent read only the title and the bold statements of each rule. This activity reads each rule and each vocabulary in full. During the activity the engineer moved the rules of test names from elixir-testing to the new skill testing-names-given, and the agent read the new versions.
- The agent corrected four deviations of the code that it wrote:
  1. Each command has no `@typedoc`, and its `target_url` has no `| nil`. A new command holds `nil` there. The rules are a-schema-declares-its-type-t-above-the-schema and a-schema-typedoc-follows-the-fields-and-associations-template.
  2. `ShortCode.validate/2` stated the form with `validate_change/3`, where the built-in `validate_format/3` states it. The rule is a-rule-the-built-in-validations-cannot-state-is-a-private-validation-function. `valid?/1` now uses the same regex, so that one regex states the form. The regex is built in a function, because Elixir deprecates a regex in a module attribute on Erlang/OTP 28.
  3. `short_code_test.exs` had its own `errors_on/1`. The rule is a-context-is-tested-through-its-public-functions, which reads errors through the shared `errors_on/1`.
  4. The test "resolves the short URL of the chosen short code to the target URL" had no condition, and its siblings differ by condition. The rule is a-test-name-states-the-outcome-then-the-condition.
- The agent read `mix help test`, `mix help format`, and `mix help compile` before it ran the tasks, by the a-mix-task-is-read-with-mix-help-before-it-is-run rule. In the earlier activities it did not. `mix test` is an alias of the project that also runs `ecto.create` and `ecto.migrate` on the test database.
- The agent kept `drop_empty_change/2`. The code inspector found that Ecto casts a field of spaces to `nil`. The default empty values of Ecto 3.14 are `[""]` only, in `deps/ecto/lib/ecto/changeset.ex`, so a field of spaces is cast as spaces. The inspector was wrong, and the function is necessary.
- The agent did not change these deviations, because the code is older than this feature and the same form is in the other slices:
  - The `changeset/2` of each command has a `@spec`, and no `@doc false`.
  - The `with` of each shortening page has an `else` that interprets the errors of several steps.
  - The test modules of the shortening slices run with `async: false`.
- `mix dialyzer` was not run. The project has no `dialyxir` dependency.
- `mix test` passes in the sprite with 125 tests. `mix compile --force --warnings-as-errors` and `mix format --check-formatted` pass.
