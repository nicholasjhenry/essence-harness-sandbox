# Add the setup of a sprite

## Activity

The agent added the setup script of a sprite, and the rule in `AGENTS.md` that sets a sprite up before the work of an endeavor starts in it, at the request of the engineer: "Let's add setup instructions to AGENTS.md to run `PROJECT_ROOT/sprite-setup.sh` that include A2, A3, A4, and A5", and "I guess the cloning cannot be in the setup script but in the AGENTS instructions". The activity belongs to no endeavor.

## Work products

- `sprite-setup.sh` — made
- `AGENTS.md` — changed: the section "A sprite is set up before the work of an endeavor starts in it"

## Agent skills

- rule-speak
- simplified-technical-english
- version-control

## Decisions

- The clone is step 2 of R1 in `AGENTS.md`, and not a step of the script. The script is in the repository, so it runs only after the clone.
- The login of the GitHub CLI is step 1 of R1, and the engineer does it. `essence-harness` and `agents-playbook` are private, so the clone needs the login first. R2 keeps the token out of each tool call of the agent.
- `--name` and `--email` are required. A new sprite has the global `user.email` `noreply@sprites.dev`, which the agent found on the sprite `mcp-essence-harness-sandbox`.
- The script first checks that each link in `.essence/system/` and `.claude/skills/` resolves, so that a clone with no submodules stops it before a change.
- The script creates the service `shortener` with `sprite-env services create`, and deletes a service of the same name first, so that the script can run again.
- The agent tested the script with `shellcheck`, with its options, and on the clone of the sprite `mcp-essence-harness-sandbox`, which has no submodules. The script stopped at the check of the links, and changed nothing. The agent did not run the full script, because the sprite has no GitHub login.
