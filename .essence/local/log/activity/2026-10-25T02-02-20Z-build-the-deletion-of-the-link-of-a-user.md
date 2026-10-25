# Build the deletion of the link of a user

## Activity

Build by feature, of the feature-driven-development practice, for the feature Delete the link of a user. The feature reached the code and code inspection milestones. The integration milestone waits for the merge of the engineer.

## Entry criteria

- Feature Design Inspected: the milestone date of the design inspection in `.essence/local/work-products/features/delete-the-link-of-a-user.md`. Held.

## Work products

- `lib/shortener/shared/link_deleted.ex` — made
- `lib/shortener/features/delete_link_of_user/link_owner.ex` — made
- `lib/shortener/features/delete_link_of_user/command_handler.ex` — made
- `lib/shortener/features/delete_link_of_user/controller.ex` — made
- `lib/shortener/features/shorten_target_url_for_user/user_link_count.ex` — changed
- `lib/shortener/features/resolve_target_url_of_short_url/link_target.ex` — changed
- `lib/shortener/features/list_links_of_user/user_links.ex` — changed
- `lib/shortener/features/list_links_of_user/live.ex` — changed
- `lib/shortener/projections/short_code_claimed.ex` — changed: the moduledoc
- `lib/shortener_web/router.ex` — changed
- `test/shortener/features/delete_link_of_user/command_handler_test.exs` — made
- `test/shortener/features/delete_link_of_user/controller_test.exs` — made
- `test/shortener/features/list_links_of_user/live_test.exs` — changed
- `.essence/local/work-products/features/delete-the-link-of-a-user.md` — changed: the milestone dates and the code inspection

## Agent skills

- feature-driven-development
- elixir-core and elixir-testing, as the substitute for the code
- testing-names-given
- code-review, as the substitute, used by the inspector
- version-control
- simplified-technical-english

## Decisions

- The required practice "Code a feature" is not met. No installed practice has an activity in Implement the System that gives the code and the unit tests of a feature. The agent evaluated the elixir-core, elixir-ecto, elixir-otp, elixir-testing, elixir-typespec, and testing-names-given skills. The elixir-core and the elixir-testing skills are the substitute. They describe Elixir code and its ExUnit tests, which is work in Implement the System. The work gave the code and the unit tests of the design, and each unit test passes: `mix test` gave 156 tests with no failure.
- The required practice "Inspect the code of a feature" is not met. No installed practice has an activity in Test the System that gives the acceptance or the rejection of the code of a feature. The agent evaluated the code-review, the security-review, and the simplify skills. The code-review skill is the substitute. It reviews a diff for correctness, which is work in Test the System, and with an inspector who is not the author, it gives the acceptance or the rejection of the code. The security-review skill reviews only security, and the simplify skill changes the code.
- The inspector was a sub-agent in a session other than the session of the author. It accepted the code, with no blocking finding.
- The code was written and tested in the sprite `mcp-essence-harness-sandbox`, on its branch `feat/delete-the-link-of-a-user`, at its commit `9ac31ca`. The agent moved the change to the local work branch with `git format-patch` and `git apply`. The sprite and the local tree hold the same code before `main` at `1bbd072`, outside `.essence`.
- The integration milestone is not recorded. By R6 of the rule `a-reviewer-overrides-entry-criteria-and-delegated-work-ends-in-a-pull-request`, only the engineer requests the merge into `main`. Each activity on the scope that started is committed, and the integration waits for a decision of the engineer, so the work of the delegation on the work branch is complete by R7. The agent opens the pull request by R8.
