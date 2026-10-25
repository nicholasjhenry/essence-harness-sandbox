# Design the deletion of the link of a user

## Activity

Design by feature, of the feature-driven-development practice, for the feature Delete the link of a user. The feature reached the domain walkthrough, design, and design inspection milestones.

## Entry criteria

- Feature Planned: `.essence/local/endeavors/2026-10-25T01-54-22Z-delete-the-link-of-a-user/requirements.md` lists the feature record, and the record holds plan position 6. Held.
- Software System Architecture Selected: the adoption record `.essence/local/endeavors/2026-10-25T01-54-22Z-delete-the-link-of-a-user/2026-10-25T01-54-53Z-software-system-1-architecture-selected.md`. Held.

## Work products

- `.essence/local/work-products/vocabulary.md` — changed: the term deletion
- `.essence/local/work-products/domain-model.md` — changed: the concept Deletion, its associations, hard constraints 1 and 8, and the notes of the walkthrough
- `.essence/local/work-products/features/delete-the-link-of-a-user.md` — changed: the milestone dates, the design, and the design inspection

## Agent skills

- feature-driven-development
- concept-speak
- simplified-technical-english
- elixir-core, as the substitute, used by the inspector
- version-control

## Decisions

- The engineer delegated the domain walkthrough: "delegated to you". The agent decided each part of the walkthrough, and wrote each decision as a note of the domain model. The decisions: only the owner deletes a link. A deletion cannot be undone. The short code of a deleted link is given to no new link. A deleted link does not count against the link limit. A request for a link that the user does not own gets the same answer as a request for a short code of no link. The user deletes a link from the list of the links of the user, after a confirmation.
- The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance or the rejection of a design. The agent evaluated the elixir-core, elixir-ecto, elixir-otp, elixir-testing, code-review, and grilling skills. The elixir-core skill is the substitute. It describes the review of Elixir code and its operations, which is work in Shape the System for a design that names Elixir modules and operations. With an inspector who is not the author, the work gives the acceptance or the rejection of the design. The code-review skill reviews a diff, and no diff exists before the code. The grilling skill asks the engineer, and the endeavor is delegated.
- The inspector was a sub-agent in a session other than the session of the author. The first inspection rejected the design for a missing test of the append conditions. The author added the tests, and the second inspection accepted the design.
- The delete action is a controller with `DELETE /links/:short_code`, and not an event of the LiveView of the list. Decision 5 of the architecture gives a slice with no page a controller, and the slice then holds the whole feature.
