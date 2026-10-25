# Build the count of the resolutions of a link

## Activity

Build by feature, of the feature-driven-development practice, for the feature Count the resolutions of a link. The feature reached the code and code inspection milestones. The integration milestone waits for the request of the engineer to merge the work branch.

## Work products

- `lib/shortener/shared/short_url_resolved.ex` — made
- `lib/shortener/features/resolve_target_url_of_short_url/command_handler.ex` — made
- `lib/shortener/features/resolve_target_url_of_short_url/resolved_link.ex` — made
- `lib/shortener/features/resolve_target_url_of_short_url/controller.ex` — changed
- `lib/shortener/features/resolve_target_url_of_short_url/resolution.ex` — removed
- `lib/shortener/features/resolve_target_url_of_short_url/link_target.ex` — removed
- `lib/shortener/features/list_links_of_user/resolution_counts.ex` — made
- `lib/shortener/features/list_links_of_user/listed_link.ex` — made
- `lib/shortener/features/list_links_of_user/link_list.ex` — changed
- `lib/shortener/features/list_links_of_user/live.ex` — changed
- `test/shortener/features/resolve_target_url_of_short_url/command_handler_test.exs` — made, from `resolution_test.exs`
- `test/shortener/features/resolve_target_url_of_short_url/controller_test.exs` — changed
- `test/shortener/features/list_links_of_user/link_list_test.exs` — changed
- `test/shortener/features/list_links_of_user/live_test.exs` — changed
- `test/shortener/features/delete_link_of_user/command_handler_test.exs` — changed
- `.essence/local/work-products/features/count-the-resolutions-of-a-link.md` — changed: the code inspection, and two milestone dates

## Agent skills

- feature-driven-development
- elixir-core
- testing-names-given, applied by the author and by the inspector
- version-control

## Decisions

- The entry criterion of Build by feature holds. Feature Design Inspected: the feature record holds the date of the design inspection milestone.
- The required practice "Code a feature" is not met. No installed practice has an activity in Implement the System that gives the code and the unit tests of a feature. The agent evaluated the elixir-core, elixir-testing, elixir-ecto, and testing-names-given skills. The elixir-core skill is the substitute, with testing-names-given for the names of the tests. It describes Elixir code and its ExUnit tests, which is work in Implement the System that gives the code and the unit tests of a feature. Its work ended with each unit test passing: `mix test` gave 172 tests with no failure in the sprite `mcp-essence-harness-sandbox`.
- The required practice "Inspect the code of a feature" is not met. No installed practice has an activity in Test the System that gives the acceptance or the rejection of code. The agent evaluated the code-review, testing-names-given, and elixir-testing skills. The inspector applied testing-names-given as the substitute, in a session of its own, and read the diff against the design. It describes the names of the tests, which is work in Test the System that, with the review of the inspector, gives the acceptance or the rejection of the code.
- The inspector accepted the code with no blocking defect. The code takes findings 1, 2, and 4 after the acceptance. The three changes name the errors of the controller, rename two tests, and move a module attribute. `mix test` then gave 172 tests with no failure again, and `mix format --check-formatted` passed.
- The page selects the header of the column `Resolutions` with `th`, because the ID `links` of the table is on its body.
- The work of the delegation on the work branch is complete by R7 of the delegation rule, after this commit. The integration milestone needs the request of the engineer to merge. The agent pushes the work branch and opens the pull request, and waits.
