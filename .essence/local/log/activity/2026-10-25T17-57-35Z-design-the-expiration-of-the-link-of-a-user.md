# Design the expiration of the link of a user

## Activity

Design by feature, of the feature-driven-development practice, for the feature Expire the link of a user. The feature reached the domain walkthrough, design, and design inspection milestones.

## Work products

- `.essence/local/work-products/features/expire-the-link-of-a-user.md` — changed: the request, the design, the design inspection, and three milestone dates

## Agent skills

- feature-driven-development
- elixir-core, elixir-testing, and elixir-ecto, by the inspector
- simplified-technical-english

## Decisions

1. The entry criteria of Design by feature hold. Feature Planned: `.essence/local/endeavors/2026-10-25T17-51-19Z-expire-the-link-of-a-user/requirements.md` lists the feature record, and the plan approval rests on the delegation. Software System Architecture Selected: the adoption record `2026-10-25T17-51-27Z-software-system-1-architecture-selected.md` of the endeavor.
2. The domain walkthrough milestone rests on the walkthrough that `.essence/local/work-products/domain-model.md` records, which rests on the delegation: "delegated".
3. The required practice "Inspect the design of a feature" is not met by an installed practice. The agent evaluated the code-review, elixir-core, elixir-testing, and elixir-ecto skills. The inspection by a new agent session with elixir-core, elixir-testing, and elixir-ecto is the substitute. Those skills describe the Elixir, the tests, and the forms of the design, which is work in Shape the System that gives the acceptance or the rejection of a design by an inspector who is not its author.
4. The inspector accepted the design, with no blocking finding. The design takes findings 1 to 5 and 7, and states finding 6 as a limit. The feature record lists each finding.
5. The projection of the link of a short code moves to `lib/shortener/projections/` as `LinkOfShortCode`, because the slices of the resolution and of the expiration need it, by decision 5 of the architecture.
6. The event is `LinkExpirationSet`, because the event of an expiration sets a time, and the link expires later.
