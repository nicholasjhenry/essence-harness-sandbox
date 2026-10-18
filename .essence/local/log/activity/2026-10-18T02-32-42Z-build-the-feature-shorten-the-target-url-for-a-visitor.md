# Build the feature shorten the target URL for a visitor

## Activity

Build by feature, of the feature-driven-development practice, for "Shorten the target URL for a visitor". The activity takes the feature through the code and code inspection milestones.

## Work products

- `lib/shortener/shared/short_code.ex`, `target_url.ex`, `link_shortened.ex`, `short_code_choice.ex`
- `lib/shortener/projections/short_code_claimed.ex`
- `lib/shortener/features/shorten_target_url_for_visitor/` — `command.ex`, `command_handler.ex`, `live.ex`
- `lib/shortener_web/components/link_components.ex` — the short URL and its copy button
- `lib/shortener_web/router.ex`, `lib/shortener_web/components/layouts.ex`, `assets/js/app.js`
- `test/shortener/features/shorten_target_url_for_visitor/`, `test/shortener/shared/short_code_test.exs`
- `.essence/local/work-products/features/shorten-the-target-url-for-a-visitor.md` — the dates of the code and code inspection milestones

## Agent skills

- feature-driven-development, arc-dcb, arc-vertical-slice, elixir-core, elixir-testing, phoenix-liveview, code-review, version-control

## Decisions

- The required practices "Code a feature" and "Inspect the code of a feature" are not met, as for the feature Assign the plan to a user. The substitutes are the same: the elixir-core, elixir-testing, phoenix-liveview, arc-dcb, and arc-vertical-slice skills for the code, and the code-review skill for the inspection. The reason is the same as in the build entry of that feature.
- An inspector in a new session accepted the code of this feature and of the next feature in one inspection, with a verdict for each. It listed eight minor findings. The agent fixed F1, F2, F3, F5, F6, and F7, and amended the design for F4. The inspector confirmed both verdicts after the fixes, and listed F9: a missing changed line of a feature record, which this activity adds.
- `mix test` gave 66 tests and no failure on the working tree of both features.
- `ShortCode.generate/0` drops each random byte at or above 248, so that each of the 62 characters is equally probable. The inspector of the design found this in finding 7.
- The short URL is the URL of the endpoint, `/`, and the short code. The link shortener does not resolve it in this endeavor, as the architecture states.
- `ShortenerWeb.LinkComponents` is in the web layer and not in a slice, because the pages of this feature and of the next feature show the short URL.
