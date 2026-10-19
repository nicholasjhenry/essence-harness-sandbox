# Log the login link in development

**Activity:** an amendment of the feature "Send the login link to a user", of the feature-driven-development practice, at the request of the engineer: "Can you output a link in the logs (local only) so I can click on that to test locally". Endeavor: `2026-10-18T02-55-34Z-resolve-short-urls-and-log-in-users`.

## Work products

- `config/dev.exs` — changed: `config :shortener, log_login_links: true`
- `lib/shortener/features/send_login_link_to_user/live.ex` — changed: `log_login_link/2`
- `test/shortener/features/send_login_link_to_user/live_test.exs` — changed: two tests
- `.essence/local/work-products/features/send-the-login-link-to-a-user.md` — changed: step 6 of the sequence, and its tests

## Agent skills

- feature-driven-development
- version-control
- elixir-core, elixir-testing, as substitutes for "Code a feature"

## Decisions

- The setting is in `config/dev.exs` only. The test and the production configurations do not set it, and the default is false. A login link in a log of production would let each reader of the log log in as the user.
- The log line is at the level `info`. The logger of development prints `debug` and above.
- The name of the feature does not change, so its milestone dates stay. The agent did not take the amendment through a new design inspection and code inspection. The change is two functions and one setting, and the engineer can inspect it in the diff of the work branch.
- `mix test` gave 106 tests and 0 failures, and `mix compile --warnings-as-errors` gave no warning.
