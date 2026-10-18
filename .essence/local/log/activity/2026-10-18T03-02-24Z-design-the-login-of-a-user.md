# Design the login of a user

**Activity:** Design by feature, of the feature-driven-development practice, for the feature set Logging in a user. Endeavor: `2026-10-18T02-55-34Z-resolve-short-urls-and-log-in-users`.

## Work products

- `.essence/local/work-products/features/send-the-login-link-to-a-user.md` — changed: the design and three milestones
- `.essence/local/work-products/features/redeem-the-login-token-of-a-user.md` — changed: the design and three milestones
- `.essence/local/work-products/features/end-the-login-session-of-a-user.md` — changed: the design and three milestones

## Agent skills

- feature-driven-development
- arc-dcb, as a substitute
- phoenix-auth, as a substitute

## Decisions

- The entry criteria hold for the three features: each one is Planned, and Software System is Architecture Selected.
- The domain walkthrough is the request of the engineer and the answers Q2 to Q4, recorded in the notes of the domain model.
- The login session is a fold of the events of its tag `login_session:` and the hash of the session token.
- A login token is valid up to and at 900 seconds after it is sent.
- A login session has no lifetime. It ends at the logout.
- The login page sends a login link to any email address, with no limit of rate. This is a risk, and the request names no limit.
- The logout broadcasts `disconnect` on the `live_socket_id` of the session.
- The corrections after the first inspection: Swoosh and its configuration in the design, the router stated in full, and the test helper `log_in_user/2`.
- The design inspection: a new agent session read only the work products and the code, and was the inspector. It rejected four designs in its first inspection, with five blocking defects. The agent corrected them, and the inspector accepted each design in its second inspection.
- The required practice "Inspect the design of a feature" is not met. No installed practice has an activity in Shape the System that gives the acceptance of a design. The agent evaluated the arc-dcb, phoenix-auth, testing-heuristics, and reviewing-requirements skills. The substitutes are arc-dcb and phoenix-auth, from `/Users/nicholas/Workspaces/agents/playbook/src/skills/`. The inspector checked each design against their rules. arc-dcb describes the review of decision models, append conditions, and tags, and phoenix-auth describes the login flow and the placement of routes. With the inspection by a session that is not the author, they give the acceptance or the rejection of the design.
