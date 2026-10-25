# Code the choice of the short code of a link

## Activity

Build by feature, of the feature-driven-development practice, for the feature Choose the short code of a link. The feature reached the code and the code inspection milestones. The integration milestone follows the merge of the work branch.

## Work products

- `lib/shortener/shared/short_code.ex` — changed. It has `validate/2`.
- `lib/shortener/shared/short_code_choice.ex` — changed. It has `candidates/1`.
- `lib/shortener/features/shorten_target_url_for_visitor/command.ex` and `live.ex` — changed. They have the field `short_code`.
- `lib/shortener/features/shorten_target_url_for_user/command.ex` and `live.ex` — changed. They have the field `short_code`.
- `test/shortener/shared/short_code_test.exs`, `test/shortener/shared/short_code_choice_test.exs`, `test/shortener_web/router_test.exs`, and the command handler tests and the page tests of the two shortening slices — made or changed.
- `.essence/local/work-products/features/choose-the-short-code-of-a-link.md` — changed. It holds the code inspection, and the dates of the code and the code inspection milestones.

## Agent skills

- feature-driven-development
- version-control
- elixir-core, elixir-ecto, and elixir-testing, as the substitute for a required practice
- elixir-typespec
- code-review, in the session of the inspector, as the substitute for a required practice

## Decisions

- The entry criterion of Build by feature holds. The feature is Design Inspected, by `.essence/local/work-products/features/choose-the-short-code-of-a-link.md`.
- The required practice "Code a feature" is not met. No installed practice has an activity in Implement the System that gives the code and the unit tests of a feature. The engineer added the elixir skills in `7a45c23`. The agent evaluated elixir-core, elixir-ecto, elixir-testing, elixir-typespec, elixir-otp, and elixir-livebook. Together, elixir-core, elixir-ecto, and elixir-testing are the substitute. They describe Elixir code, Ecto changesets, and ExUnit tests, which is work in Implement the System. The work gave the code and the unit tests of the feature from its design, with each test passing. elixir-otp and elixir-livebook describe processes and notebooks, which this feature does not have. The agent used elixir-typespec for the specs.
- The agent read the title and the bold statements of each rule of the four skills, and not the examples. The rule files hold 228 KB.
- The elixir-typespec skill asks for `mix dialyzer` after a change to a spec. The project has no `dialyxir` dependency, so the agent did not run it. To add the dependency is outside the request.
- The required practice "Inspect the code of a feature" is not met. The agent evaluated the code-review, security-review, and simplify skills again for this activity. The code-review skill is the substitute. It reviews code for defects of correctness, and the inspector accepts or rejects the code from its findings. That is work in Test the System that gives the result of the required practice. security-review covers only security, and simplify changes the code.
- The inspector was an agent in a session other than the session of the author. It accepted the code with five findings that do not block. The code does not take them, so that the commit holds the code that the inspector accepted. The feature record lists them.
- `mix test` in the sprite gave 125 tests with no failure: the 106 tests of `main` and 19 new tests. `mix format --check-formatted` passed. The warning `unused require Logger` in `test/shortener/features/send_login_link_to_user/live_test.exs` comes from `498148e`, and this feature does not change that file.
- The command handlers of the two shortening slices did not change, by the design.
- The work branch was rebased onto `main` at `7a45c23`, after the engineer added the skills. The four earlier commits of the branch were replayed with no conflict.
