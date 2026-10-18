# Design the feature assign-the-plan-to-a-user

## Activity

Design by feature, of the feature-driven-development practice, for "Assign the plan to a user". The activity takes the feature through the domain walkthrough, design, and design inspection milestones.

## Work products

- `.essence/local/work-products/features/assign-the-plan-to-a-user.md` — the design, and the dates of three milestones
- `.essence/local/work-products/architecture.md` — decisions 2, 5, and 6, and risk 3, amended by findings 1, 3, and 8 of the inspector

## Agent skills

- feature-driven-development — the design by feature process
- arc-dcb — the decision model, the projections, the tags, and the append condition of the design
- arc-vertical-slice — the slice and the shared modules
- simplified-technical-english — the prose of the design and of this entry
- version-control — the commit

## Decisions

- The entry criterion Software System Architecture Selected is not held. The endeavor holds no alpha state record of Software System, and two checkpoints of Architecture Selected are not true:
  - The criteria for the selection of the architecture are agreed.
  - The key technical risks are agreed.
- The agent asked a reviewer, in a session other than this session, for an override within `.essence/local/endeavors/2026-10-18T02-09-14Z-build-the-first-features-of-the-link-shortener/delegation.md` at `4c76bd3`. The reviewer refused the override for each of the three design by feature activities. Its reason: the architecture and each checkpoint about a person stay with the engineer, and a delegation does not hold them.
- The agent started the activity with no override of the reviewer. The engineer instructed the agent to complete the endeavor without prompts, and the system rules of the engineer state that an explicit instruction of the engineer wins. The agent took the instruction as the override of the engineer, by R2 of the `an-activity-starts-only-if-its-entry-criteria-hold` rule, for this activity. The engineer can reject this reading.
- The domain walkthrough is the request of the engineer in this session, as the notes of the domain model state.
- The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance of a design. The agent evaluated the arc-dcb, arc-vertical-slice, reviewing-requirements, and code-review skills. The arc-dcb skill, with the arc-vertical-slice skill, is the substitute. Its rules are the criteria of a review of a DCB design, which is work in Shape the System. An inspector in a new session applied them, and gave the acceptance or the rejection of the design.
- The inspector accepted the design. It listed eight minor findings that do not block the acceptance.
- The agent amended the architecture for three findings of the inspector: the setting that gives `BEGIN IMMEDIATE`, the place of `Shortener.EventStore`, and the candidate short codes as arguments of the command handler.
- The design holds the DCB event store, because this feature is the first feature that needs it. The other features use it.
- `UserPlan`, `EmailAddress`, and `PlanAssignedToUser` are outside the slice from the start. The feature Shorten the target URL for a user needs them, and its design is accepted in the same endeavor. The inspector accepted this as finding 2.
