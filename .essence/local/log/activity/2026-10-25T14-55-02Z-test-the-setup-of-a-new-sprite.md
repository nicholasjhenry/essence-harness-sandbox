# Test the setup of a new sprite

## Activity

The agent set up the new sprite `mcp-shortener-setup-test` by the three steps of R2 of the sprite section of `AGENTS.md`, at the request of the engineer: "do you want to try this out in a new sprite?", and "could this be something you automatically run and give me the heads up you'll need me to authenticate?". The activity belongs to no endeavor.

## Work products

- `sprite-auth.sh` — changed: the output of `gh auth status` has no `Token:` line
- `AGENTS.md` — changed: the agent runs step 1 of R2 after it tells the engineer, and a new example for the `Token:` line

## Agent skills

- rule-speak
- simplified-technical-english
- version-control

## Decisions

- The agent pushed `build/vendor-the-playbook` to `origin`, so that the sprite could clone the scripts and the submodule `.vendor/agents-playbook`.
- The agent ran `./sprite-auth.sh mcp-shortener-setup-test` after it told the engineer to expect the approval of 1Password. The login worked. `gh auth status` showed the start of the fine-grained token, `github_pat_` and its identifier, in the output of the tool. The secret part was masked by `gh`. The agent changed the script to remove the `Token:` line, and checked the filter on the sprite. The engineer can rotate the token to remove each doubt.
- The results on the sprite: the clone with `--recurse-submodules` of `build/vendor-the-playbook` got both private submodules, and each link in `.essence/system/` and `.claude/skills/` resolved. `./sprite-setup.sh` gave exit status 0, and again 0 on a second run. `mix test` gave 137 tests with no failure. `/`, `/log-in`, and `/dev/mailbox` gave 200 on port 8080. `git push --dry-run` to a new branch passed.
