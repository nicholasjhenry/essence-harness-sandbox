# Design the check of the availability of a short code

## Activity

Design by feature, of the feature-driven-development practice, for the feature Check the availability of a short code. The feature reached the domain walkthrough, design, and design inspection milestones.

The entry criteria held. The feature is Planned: `.essence/local/endeavors/2026-10-25T21-22-35Z-check-the-availability-of-a-short-code/requirements.md` lists its record, and the record holds plan position 2. Software System is Architecture Selected, by `.essence/local/endeavors/2026-10-25T21-22-35Z-check-the-availability-of-a-short-code/2026-10-25T21-22-44Z-software-system-1-architecture-selected.md`.

## Work products

- `.essence/local/work-products/domain-model.md` — changed. The short code has the property availability, and the notes hold the decisions of the walkthrough.
- `.essence/local/work-products/features/check-the-availability-of-a-short-code.md` — changed. It holds the design, the design inspection, and the dates of three milestones.

## Agent skills

- feature-driven-development
- concept-speak, for the property availability
- simplified-technical-english
- elixir-core, elixir-testing, and testing-names-given, applied by the inspector

## Decisions

1. The engineer walked through the part of the domain that the feature uses. The walkthrough rests on the delegation: "delegated". The domain model records each decision of the walkthrough in its notes.
2. The availability is a property of the short code, and not a new concept. The domain vocabulary does not change.
3. A short code of a deleted link is taken, so that the check and the submission give the same answer for the same events.
4. The check runs for a visitor and for a user, because each person who shortens can choose a short code.
5. The check is a read, and the submission keeps its own check, by the request: "The check at the submission stays".
6. The page shows a message, and does not disable the button.
7. `ShortCodeAvailability` is in `lib/shortener/shared/`, because two slices need it, by decision 5 of the architecture.
8. The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance or the rejection of a design. The agent evaluated the elixir-core, elixir-testing, testing-names-given, code-review, and simplify skills. The substitute is an agent in a new session that applies the elixir-core, elixir-testing, and testing-names-given skills. The inspector is not the author, and its verdict gives the acceptance or the rejection of the design, which is the result of the required practice. code-review and simplify review a diff of code, and not a design.
9. The inspector accepted the design, with no blocking finding. The design takes findings 1, 2, 4, 5, and 6, and does not take findings 3 and 7. The feature record gives each finding and the reason.
