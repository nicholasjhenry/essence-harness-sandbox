# Design the listing of the links of a user

## Activity

Design by feature, of the feature-driven-development practice, for List the links of a user. The feature reached the domain walkthrough, design, and design inspection milestones.

The entry criteria held: the feature is Planned, and Software System is Architecture Selected by the adoption record of this endeavor.

## Work products

- `.essence/local/work-products/domain-model.md` — five notes of the walkthrough of the listing.
- `.essence/local/work-products/features/list-the-links-of-a-user.md` — the design, the design inspection, and three milestone dates.

## Agent skills

- feature-driven-development
- concept-speak
- simplified-technical-english
- elixir-core, elixir-testing, and testing-names-given — used by the inspector, as the substitute for the required practice "Inspect the design of a feature".

## Decisions

- The engineer walked through the domain by the delegation statement "delegating this to you fully". The agent asked no question, and recorded the decisions of the walkthrough as notes in the domain model.
- The listing adds no concept to the domain vocabulary or the domain model.
- The list is on a page of its own, `/links`, and not on the page that shortens a target URL. Each feature then keeps its own slice.
- The list has no pages, and holds each link of the user, the newest first.
- The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance or the rejection of a design. The agent evaluated the skills code-review, simplify, elixir-core, elixir-testing, elixir-typespec, elixir-otp, elixir-ecto, and testing-names-given. code-review and simplify review a diff, and no diff exists before the code. The substitute is an agent in a new session with elixir-core, elixir-testing, and testing-names-given. These skills describe the Elixir code and the tests that the design states, and the agent gives an acceptance or a rejection, which is the result of the required practice.
- The inspector accepted the design with no blocking defect, and gave eight findings that do not block. The feature record lists them, with the response of the code to each.
- The menu keeps the name `Your links` for the page that shortens a target URL, beside the new `All your links`. A rename is not in the request.
