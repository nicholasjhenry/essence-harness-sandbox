# Select the architecture of the link shortener

## Activity

Select the architecture, of the feature-driven-development practice.

## Work products

- `.essence/local/work-products/architecture.md` — made in this activity

## Agent skills

- feature-driven-development — the select the architecture activity, and the seven items of R2 of the `the-architecture-is-selected-before-the-first-feature-is-designed` rule
- arc-dcb — the read and append interface, the append condition, the decision model, and the tags
- arc-vertical-slice — the organization of the code by slice
- simplified-technical-english — the prose of the document and of this entry
- version-control — the commit

## Decisions

- The engineer approved D1 and D2 of the first response of the agent: an event store in SQLite through `ecto_sqlite3`, and a Phoenix 1.8 application in this repository. The engineer gave the approval with the instruction "complete the endeavor". The other items of the architecture follow from D1, D2, and the request. The engineer did not see the criteria and the risks.
- The agent took the instruction of the engineer to complete the endeavor without prompts in place of the approval of the whole architecture that R1 of the `the-architecture-is-selected-before-the-first-feature-is-designed` rule requires. An explicit instruction of the engineer wins over a rule, by the system rules of the engineer.
- The agent did not write an alpha state record of Software System Architecture Selected. Two of its checkpoints are about a person: "The criteria for the selection of the architecture are agreed" and "The key technical risks are agreed". The engineer did not confirm them, so R3 of the `a-checkpoint-is-marked-true-only-with-its-evidence` rule keeps them not true. Each design by feature activity therefore needs an override of its entry criterion Software System Architecture Selected, within the delegation.
- The agent selected SQLite over PostgreSQL, because the computer of the engineer has no PostgreSQL server. Docker is installed, but a container is an external service that each test run needs.
- The agent selected an event store of this repository over a library. The arc-dcb skill states the whole interface, and the append condition is the part that each hard constraint rests on.
- The LiveView of each slice is named `Live`, in `live.ex`, by the `a-file-in-a-slice-is-named-for-its-role` rule of the arc-vertical-slice skill. The phoenix-liveview skill names a LiveView module with a `Live` suffix. The module `Shortener.Features.AssignPlanToUser.Live` meets both.
