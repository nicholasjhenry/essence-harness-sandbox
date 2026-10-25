# Design the count of the resolutions of a link

## Activity

Design by feature, of the feature-driven-development practice, for the feature Count the resolutions of a link. The feature reached the domain walkthrough, design, and design inspection milestones.

## Work products

- `.essence/local/work-products/domain-model.md` — changed: the properties time of resolution and target URL of a resolution, the association of a link with its resolutions, and the notes of the walkthrough
- `.essence/local/work-products/features/count-the-resolutions-of-a-link.md` — changed: the design, the design inspection, and three milestone dates

## Agent skills

- feature-driven-development
- concept-speak
- simplified-technical-english
- elixir-testing, applied by the inspector

## Decisions

- The entry criteria of Design by feature hold. Feature Planned: `.essence/local/endeavors/2026-10-25T15-27-26Z-count-the-resolutions-of-a-link/requirements.md` lists the feature record, the record holds plan position 3, and the engineer approved the plan with the request "implement: Count the resolutions of a link". Software System Architecture Selected: the adoption record of the endeavor gives it.
- The engineer delegated the decisions of the walkthrough: "completely delegated". The agent made each decision of the walkthrough, and recorded it as a note of the domain model. The engineer did not walk through the domain in a prompt.
- The link shortener records each resolution with the status `302 Found`, of a link of a visitor or of a user, and no resolution with the status `404 Not Found`.
- The event `ShortUrlResolved` holds the target URL of the resolution, and the tag of the owner where the link has an owner. The tag of the owner lets the page of the links of a user read the resolutions of the user in the same read as the links.
- The count is a projection of the slice `list_links_of_user`, and not a table, by decision 9 of the architecture.
- The resolution gets a command handler, and the modules `Resolution` and `LinkTarget` are removed, by decisions 4 and 5 of the architecture.
- The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance or the rejection of a design. The agent evaluated the elixir-core, elixir-testing, code-review, and simplify skills. The inspector applied elixir-testing as the substitute, in a session of its own. It describes the tests that a design names, which is work in Shape the System that, with the review of the inspector, gives the acceptance or the rejection of the design. The code-review and simplify skills review a diff, and no code was written.
- The inspector accepted the design with no blocking defect. The code takes findings 1, 3, 4, and 5 of the inspection. Finding 2 is not taken, for the reason that the feature record states.
