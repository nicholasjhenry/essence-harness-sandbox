# Design the resolution of a short URL

**Activity:** Design by feature, of the feature-driven-development practice, for the feature set Resolving a short URL. Endeavor: `2026-10-18T02-55-34Z-resolve-short-urls-and-log-in-users`.

## Work products

- `.essence/local/work-products/features/resolve-the-target-url-of-a-short-url.md` — changed: the design, and the domain walkthrough, design, and design inspection milestones

## Agent skills

- feature-driven-development
- arc-dcb, as a substitute
- phoenix-router, from `/Users/nicholas/Workspaces/agents/playbook/src/skills/`

## Decisions

- The entry criteria hold: the feature is Planned, and Software System is Architecture Selected, by the adoption record of this endeavor.
- The domain walkthrough is the request of the engineer, recorded in the notes of `.essence/local/work-products/domain-model.md`.
- The resolution reads a decision model and appends nothing.
- The first inspection found no blocking defect. The agent took its three minor points: the 404 response sets its format and its view, the route is after each page route, and the test of a page path uses `/` and `/log-in`.
- The design inspection: a new agent session read only the work products and the code, and was the inspector. It rejected four designs in its first inspection, with five blocking defects. The agent corrected them, and the inspector accepted each design in its second inspection.
- The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance of a design. The agent evaluated the arc-dcb, phoenix-auth, testing-heuristics, and reviewing-requirements skills. The substitutes are arc-dcb and phoenix-auth, from `/Users/nicholas/Workspaces/agents/playbook/src/skills/`. The inspector checked each design against their rules. arc-dcb describes the review of decision models, append conditions, and tags, and phoenix-auth describes the login flow and the placement of routes. With the inspection by a session that is not the author, they give the acceptance or the rejection of the design.
