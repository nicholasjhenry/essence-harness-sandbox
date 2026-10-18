# Build the feature assign the plan to a user

## Activity

Build by feature, of the feature-driven-development practice, for "Assign the plan to a user". The activity takes the feature through the code and code inspection milestones. The integration milestone waits for the merge of the work branch into `main`.

## Work products

- the Phoenix 1.8.15 application `shortener`, made by `mix phx.new shortener --database sqlite3 --no-install --no-mailer --no-dashboard --no-gettext`, in place of the Mix project `essence_harness_sandbox`
- `config/config.exs` — `default_transaction_mode: :immediate`
- `priv/repo/migrations/20261018022038_create_the_event_store.exs`
- `lib/shortener/dcb/` — the modules of the DCB event store
- `lib/shortener/event_store.ex` — the SQLite event store
- `lib/shortener/shared/plan.ex`, `email_address.ex`, `plan_assigned_to_user.ex`
- `lib/shortener/projections/user_plan.ex`
- `lib/shortener/features/assign_plan_to_user/` — `command.ex`, `command_handler.ex`, `live.ex`
- `lib/shortener_web/router.ex`, `lib/shortener_web/components/layouts.ex`, `assets/css/app.css`
- `test/shortener/event_store_test.exs`, `test/shortener/dcb/decider_test.exs`, `test/shortener/features/assign_plan_to_user/`
- `.essence/local/work-products/features/assign-the-plan-to-a-user.md` — the dates of the code and code inspection milestones

## Agent skills

- feature-driven-development — the build by feature process
- arc-dcb — the event store, the projections, the decision model, and the append condition
- arc-vertical-slice — the slice `assign_plan_to_user/`
- elixir-core, elixir-testing, phoenix-liveview — the code, the tests, and the LiveView
- code-review — the approach of the inspection
- version-control — the commit

## Decisions

- The required practice "Code a feature" is not met. No installed practice has an activity in Implement the System that gives the code and the unit tests of a feature. The agent evaluated the elixir-core, elixir-ecto, elixir-testing, phoenix-contexts, phoenix-liveview, arc-dcb, and arc-vertical-slice skills. The elixir-core, elixir-testing, phoenix-liveview, arc-dcb, and arc-vertical-slice skills together are the substitute. They describe Elixir code, its ExUnit tests, the LiveView, and the DCB design, which is work in Implement the System that gives the code and the unit tests of a feature. Each unit test passes. The agent did not use phoenix-contexts, because the architecture organizes the code in slices and not in contexts.
- The required practice "Inspect the code of a feature" is not met. No installed practice has an activity in Test the System that gives the acceptance of code. The agent evaluated the code-review, security-review, and testing-heuristics skills. The code-review skill is the substitute. It describes a review of code for correctness, which is work in Test the System. An inspector in a new session applied it, and gave the acceptance or the rejection of the code.
- The inspector rejected the first code for two defects. The page crashed when the decider gave `{:error, :append_condition_failed}` after three attempts. The migration held a copy of the tags in `events`, which the design did not state. The agent fixed both, and the inspector accepted the code in a second inspection.
- The agent added `EmailAddress.validate/2`, `Plan.names/0`, and the `title` property of a plan, which the design did not list. They are the validation of the form and the text of the page.
- The agent removed the page controller that `mix phx.new` makes. The home page of the link shortener is the page of the feature Shorten the target URL for a visitor.
- No test runs two appends at the same time on a connection outside the sandbox. In the sandbox, a transaction is a savepoint, so `BEGIN IMMEDIATE` does not run. Risk 2 of the architecture stays open.
- `mix test` gave 32 tests and no failure for the code of this feature, with a new test database.
