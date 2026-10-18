# Build the authorization of a user

**Activity:** Build by feature, of the feature-driven-development practice, for the feature set Authorizing a user, to the code inspection milestone. Endeavor: `2026-10-18T02-55-34Z-resolve-short-urls-and-log-in-users`.

## Work products

- `lib/shortener/features/assign_plan_to_user/` — changed: `command.ex`, `command_handler.ex`, `live.ex`. New: `plan_of_user.ex`
- `lib/shortener/features/shorten_target_url_for_user/` — changed: `command.ex`, `command_handler.ex`, `live.ex`
- `test/shortener/features/assign_plan_to_user/`, `test/shortener/features/shorten_target_url_for_user/` — changed
- the two feature records of Authorizing a user — changed: the code and code inspection milestones

## Agent skills

- feature-driven-development
- version-control
- elixir-core, elixir-testing, phoenix-liveview, phoenix-auth, as substitutes
- elixir-core, elixir-testing, arc-dcb, phoenix-auth, as substitutes for the inspection

## Decisions

- The entry criterion holds: each feature is Design Inspected.
- Closes risk 4 of the parent architecture: no person can put a different user on a plan, or make a link for a different user.
- The required practice "Code a feature" is not met. No installed practice has an activity in Implement the System that gives the code and the unit tests of a feature. The agent evaluated the elixir-core, elixir-testing, elixir-ecto, phoenix-liveview, phoenix-router, and phoenix-auth skills, from `/Users/nicholas/Workspaces/agents/playbook/src/skills/`. The substitutes are elixir-core, elixir-testing, phoenix-liveview, phoenix-router, and phoenix-auth. Together they describe Elixir and Phoenix code and its ExUnit tests. The work ended only when each unit test passed: `mix test` gave 104 tests and 0 failures, and `mix compile --warnings-as-errors` gave no warning.
- The required practice "Inspect the code of a feature" is not met. No installed practice has an activity in Test the System that gives the acceptance of code. The agent evaluated the elixir-core, elixir-testing, arc-dcb, phoenix-auth, and code-review skills. The substitutes are elixir-core, elixir-testing, arc-dcb, and phoenix-auth. A new agent session, which did not write the code, read the diff and the designs, and checked the code against these skills. It gives the acceptance or the rejection of the code.
- The code inspection: the inspector accepted five features, and rejected "Redeem the login token of a user" for F1. The lifetime check rounded to whole seconds, and accepted a login token up to 999 ms after its lifetime. The agent fixed F1 with `DateTime.compare/2` and a test at 900 seconds and 1 microsecond. The agent also took the non-blocking points N1, N2, N4, and N5. The inspector then accepted each of the six features. The agent did not take N3, a second test of a logout during a plan assignment, because the test of the same mechanism in the link shortening proves it. It did not take N6, a log of a logout whose append fails three times.
- The commits of the three build activities share the router, the layout, and the test support. Only the last of them compiles alone. The squash commit of the work branch holds all three.
- A run of the app in development gave: `/` 200, `/log-in` 200, `/plans` 302 to `/log-in`, `/Zzz9999` 404, `/dev/mailbox` 200, and `/KJQ8erI` 302 to `https://www.example.com/`.
