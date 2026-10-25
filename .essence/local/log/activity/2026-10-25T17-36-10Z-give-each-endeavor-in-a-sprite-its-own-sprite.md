# Give each endeavor in a sprite its own sprite, and destroy the sprite after its pull requests

## Activity

The engineer requested "ok, let's do that", for the recommendation that an endeavor in a sprite starts in a new sprite, and that the sprite is destroyed after its pull request is merged or closed.

## Work products

- `AGENTS.md` — the sprite section. R2 gains the step `sprite create --skip-console <sprite>` as its first step. R7 to R10 are new: one endeavor for each sprite, the name of the sprite, the destruction after the pull requests, and the conditions of a destruction. The title, the facts, the examples, and the rationale change with them.
- `sprite-agent-prompt.md` — a new fact 4 tells the session in the sprite that the sprite holds only its endeavor, that the directory of the endeavor takes the name of the sprite as its description, and that the session does not destroy the sprite.

## Agent skills

- rule-speak — the form of R7 to R10, and the list of the conditions of R10
- simplified-technical-english — the prose of the new rules, facts, examples, and rationale
- version-control — the work branch `build/give-each-endeavor-its-own-sprite`, and the commit

## Decisions

- The sprite is destroyed when each pull request of the endeavor is merged or closed, and not when the session in the sprite ends. The description of the pull request gives the URL of the sprite, and the engineer tries the app there before the merge.
- The agent on the computer of the engineer destroys the sprite. The session in the sprite ends before the merge.
- R10 permits a destruction only if no commit or change is only in the clone, or if the engineer requests it. A destruction cannot be undone.
- The name of the sprite is the description of the endeavor, and the directory of the endeavor takes the same description. The name of the sprite then names its endeavor.
- No script changes. `sprite-auth.sh`, `sprite-setup.sh`, and `sprite-agent.sh` take the name of the sprite as an argument, and work on a new sprite. The destruction is one command, `sprite destroy --force <sprite>`, so it takes no script.
- The sprite `mcp-essence-harness-sandbox` holds the session of the endeavor Count the characters of a short code. It is not destroyed in this activity. R9 applies to it after the pull request of that endeavor.
