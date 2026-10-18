# Build the feature shorten the target URL for a user

## Activity

Build by feature, of the feature-driven-development practice, for "Shorten the target URL for a user". The activity takes the feature through the code and code inspection milestones.

## Work products

- `lib/shortener/features/shorten_target_url_for_user/` — `command.ex`, `command_handler.ex`, `user_link_count.ex`, `link_usage.ex`, `live.ex`
- `lib/shortener_web/router.ex`, `lib/shortener_web/components/layouts.ex` — the route and the link of the page
- `test/shortener/features/shorten_target_url_for_user/`
- `.essence/local/work-products/features/shorten-the-target-url-for-a-user.md` — `LinkUsage` in the design, by finding F4 of the inspector, and the dates of the code and code inspection milestones

## Agent skills

- feature-driven-development, arc-dcb, arc-vertical-slice, elixir-core, elixir-testing, phoenix-liveview, code-review, version-control

## Decisions

- The required practices "Code a feature" and "Inspect the code of a feature" are not met. The substitutes are the same as for the feature Assign the plan to a user, for the same reason.
- The inspection of this feature is the inspection that the entry of the feature Shorten the target URL for a visitor names. The inspector accepted the code, and confirmed the acceptance after the fixes.
- `LinkUsage` reads the plan and the link count of the user through the same projections as the decision, by decision 9 of the architecture. It appends nothing.
- The decision checks the link limit before it chooses a short code, so a user at the link limit gets `:link_limit_reached` and not `:short_code_taken`.
- `mix test` gave 66 tests and no failure.
