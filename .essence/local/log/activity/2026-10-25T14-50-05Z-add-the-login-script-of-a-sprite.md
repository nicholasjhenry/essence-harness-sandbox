# Add the login script of a sprite

## Activity

The agent added the script that logs the GitHub CLI of a sprite in with a token from 1Password, at the request of the engineer: "let's add that github auth script that can be used with a sprite, the token can be access from "op://Infrastructure/GitHub/credential"". The activity belongs to no endeavor.

## Work products

- `sprite-auth.sh` — made, from `bin/sprite-auth` of the closed pull request 2
- `AGENTS.md` — changed: step 1 of R2, a fact, an example, and the rationale of the sprite section
- `sprite-setup.sh` — changed: its header names the login script

## Agent skills

- rule-speak
- simplified-technical-english
- version-control

## Decisions

- The script is at the root of the repository, as `sprite-auth.sh`, beside `sprite-setup.sh`, which the engineer placed at the root.
- The default 1Password reference is `op://Infrastructure/GitHub/credential`. The `-r` option and `SPRITE_GITHUB_TOKEN_REF` still replace it.
- The login stays a step of the engineer. The GitHub connector of the sprites gives the REST API through its gateway. The agent found on the sprite `mcp-essence-harness-sandbox` that `git ls-remote` of a private repository fails with no login, and that the gateway URL is not a git remote.
- The agent tested the script with `shellcheck`, and with stub `op` and `sprite` commands: the sprite got the token on its standard input, and a failed read stopped the script with exit status 1. The agent did not run the script with the real token.
