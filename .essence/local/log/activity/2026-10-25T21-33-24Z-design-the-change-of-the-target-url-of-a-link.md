# Design the change of the target URL of a link

## Activity

Design by feature, of the feature-driven-development practice: the design and the design inspection milestones of the feature Change the target URL of a link.

## Work products

- `.essence/local/work-products/features/change-the-target-url-of-a-link.md` — changed. It holds the design, its limits, and the result of the design inspection, and records the dates of the design and the design inspection milestones.

## Agent skills

- feature-driven-development — design by feature.
- elixir-core, elixir-ecto, elixir-testing — applied by the inspector, as the substitute for the required practice Inspect the design of a feature.
- simplified-technical-english — the prose of the design.
- version-control — the commit.

## Decisions

1. The entry criteria of Design by feature hold. The feature is Planned: `.essence/local/endeavors/2026-10-25T21-28-03Z-change-the-target-url-of-a-link/requirements.md` lists its record, and the record holds plan position 6. Software System is Architecture Selected, by the adoption record of the endeavor. No override is needed.
2. The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance or the rejection of the design of a feature. The agent evaluated the elixir-core, elixir-ecto, elixir-testing, elixir-otp, elixir-typespec, testing-names-given, code-review, and simplify skills. The substitute is an inspector agent, in a session other than the session of the author, that applies the elixir-core, elixir-ecto, and elixir-testing skills. These skills describe the Elixir code, the Ecto changesets, and the ExUnit tests that the design states. The inspector reads the design against the domain model and the architecture, and gives an acceptance or a rejection, which is the result of the required practice.
3. The inspector accepted the design, with eight findings that do not block. The design takes findings 1 to 7. It does not take finding 8, because the record of the expiration of the link of a user is the design of an integrated feature.
4. `OwnedLink` moves to `lib/shortener/shared/`, by decision 5 of the architecture, because a second slice needs it. It is not a projection.
5. The decision gives `:not_found` for a new target URL that is not a target URL, and not a reason of its own. Only a caller other than the page can send one.
