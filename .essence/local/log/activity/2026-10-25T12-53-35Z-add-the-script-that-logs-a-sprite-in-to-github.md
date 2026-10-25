# Add the script that logs a sprite in to GitHub

## Activity

The agent wrote a script that logs the GitHub CLI of a sprite in with a token from 1Password, at the request of the engineer: "write a reusable script for O1". The activity belongs to no endeavor.

## Work products

- `bin/sprite-auth` — made

## Agent skills

- version-control
- simplified-technical-english

## Decisions

- The token goes from `op read` to the standard input of `gh auth login --with-token` on the sprite, through `sprite exec --stdin`. It is never an argument of a command, never in a local file, and never in the context of the agent.
- The script reads the token before it starts `sprite exec`, so that a failed read stops the script before the sprite gets an empty input.
- The 1Password reference is the `-r` option, then `SPRITE_GITHUB_TOKEN_REF`, then `op://Dev/sprite-github/token`.
- The engineer selected a branch of its own for the script, made from `main`, with its own pull request. The work branch of the deletion stays on the scope of its delegation.
- The agent tested the script with `shellcheck`, and with stub `op` and `sprite` commands: the sprite got the token on its standard input, and a failed read stopped the script with exit status 1. The agent did not run the script against the real sprite, because that needs the token of the engineer.
