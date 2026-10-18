# Select the architecture of the resolution and the login

**Activity:** Select the architecture, of the feature-driven-development practice. Endeavor: `2026-10-18T02-55-34Z-resolve-short-urls-and-log-in-users`.

## Work products

- `.essence/local/work-products/architecture.md` — changed. It adds criterion 6, Swoosh, the new boundary, the decisions 10 to 13, the reuse of the flow of `phx.gen.auth`, and the risks 6 to 10. Risk 4 is replaced.
- the adoption record of Software System Architecture Selected, in the directory of the endeavor — new

## Agent skills

- feature-driven-development
- phoenix-auth, from `/Users/nicholas/Workspaces/agents/playbook/src/skills/`
- arc-dcb, from `/Users/nicholas/Workspaces/agents/playbook/src/skills/`

## Decisions

- The endeavor inherits Software System Architecture Selected from its parent endeavor. This activity changes `architecture.md`, which is the evidence of five checkpoints of the source record. The agent assessed each checkpoint again against the changed file, and each one is true.
- The source record names the engineer as the evidence of two checkpoints: the criteria are agreed, and the key technical risks are agreed. R6 of the a-recorded-state-is-checked-again-when-its-evidence-changes rule requires the engineer to confirm them again. The engineer stated "you are fully delegated, no more prompts please", and the agent takes this statement as the confirmation of the two checkpoints for this endeavor. The agent did not show the changed criteria and risks to the engineer. The final report of the session states this.
- Swoosh is the one new dependency. It is the mailer that `phx.gen.auth` generates.
- The login session is in the event store, and not in an Ecto table. Decision 1 of the architecture permits no table other than the tables of the event store.
- The resolution is a controller action with no pipeline. It needs no session, no CSRF token, and no layout.
