# Design the authorization of a user

**Activity:** Design by feature, of the feature-driven-development practice, for the feature set Authorizing a user. Endeavor: `2026-10-18T02-55-34Z-resolve-short-urls-and-log-in-users`.

## Work products

- `.essence/local/work-products/features/authorize-the-plan-assignment-of-a-user.md` — changed: the design and three milestones
- `.essence/local/work-products/features/authorize-the-link-shortening-of-a-user.md` — changed: the design and three milestones

## Agent skills

- feature-driven-development
- arc-dcb, as a substitute
- phoenix-auth, as a substitute

## Decisions

- The entry criteria hold for the two features: each one is Planned, and Software System is Architecture Selected.
- The domain walkthrough is the answers Q3 and Q4 of the engineer, recorded in the notes of the domain model.
- Each decision reads the login session of the scope again, so that hard constraints 6 and 7 hold after a logout in a different tab. The first inspection found this defect.
- The two features change the slices of the Integrated features "Assign the plan to a user" and "Shorten the target URL for a user". The records of those two features do not change.
- The design inspection: a new agent session read only the work products and the code, and was the inspector. It rejected four designs in its first inspection, with five blocking defects. The agent corrected them, and the inspector accepted each design in its second inspection.
- The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance of a design. The agent evaluated the arc-dcb, phoenix-auth, testing-heuristics, and reviewing-requirements skills. The substitutes are arc-dcb and phoenix-auth, from `/Users/nicholas/Workspaces/agents/playbook/src/skills/`. The inspector checked each design against their rules. arc-dcb describes the review of decision models, append conditions, and tags, and phoenix-auth describes the login flow and the placement of routes. With the inspection by a session that is not the author, they give the acceptance or the rejection of the design.
