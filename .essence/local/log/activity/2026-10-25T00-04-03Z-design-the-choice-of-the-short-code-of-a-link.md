# Design the choice of the short code of a link

## Activity

Design by feature, of the feature-driven-development practice, for the feature Choose the short code of a link. The feature reached the domain walkthrough, the design, and the design inspection milestones.

## Work products

- `.essence/local/work-products/features/choose-the-short-code-of-a-link.md` — changed. It holds the design, the design inspection, and the date of each of the three milestones.

## Agent skills

- feature-driven-development
- code-review, in the session of the inspector, as the substitute for a required practice
- simplified-technical-english

## Decisions

- The entry criteria of Design by feature hold. The feature is Planned, by `.essence/local/log/activity/2026-10-24T23-57-15Z-plan-the-choice-of-the-short-code-of-a-link.md`. Software System is Architecture Selected, by `.essence/local/endeavors/2026-10-24T23-57-00Z-choose-the-short-code-of-a-link/2026-10-24T23-58-24Z-software-system-1-architecture-selected.md`.
- The engineer walked through the part of the domain that the feature uses. Evidence: the engineer, in `.essence/local/log/activity/2026-10-24T23-57-58Z-model-the-choice-of-the-short-code.md`. The walkthrough is the request of the engineer and the delegation statement of the session on Sat Oct 24 2026: "I'm delegating this endeavor complete to you".
- The command handlers of the two shortening slices do not change. A chosen short code is the one candidate of the decision, so hard constraint 1 holds by the append condition of the decision, as for each short code.
- The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance or the rejection of the design of a feature. The agent evaluated the code-review, security-review, simplify, grilling, and ai-contract-first skills. The code-review skill is the substitute. It reviews a path target for defects of correctness, and the inspector accepts or rejects the target from its findings. That is the result of the required practice. The other skills do not give it: security-review covers only security, simplify changes code, and grilling and ai-contract-first ask questions of the engineer.
- The inspector was an agent in a session other than the session of the author. It applied the code-review skill to the feature record, and accepted the design with eight findings that do not block. The code takes findings 1 to 7, as the feature record lists them.
- Finding 8 of the inspector is not taken. A visitor can choose each free short code, with no limit. The domain model gives a visitor no link limit, and this feature does not change it. The agent reports it to the engineer at the end of the endeavor.
- The code-review skill of the inspector read a file in `.essence/local/log/`. The inspector did not use the finding that came from the read. The agent did not read the log.
