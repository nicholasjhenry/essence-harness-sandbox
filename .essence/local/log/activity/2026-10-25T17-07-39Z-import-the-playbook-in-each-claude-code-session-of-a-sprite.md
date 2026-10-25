# Import the playbook in each Claude Code session of a sprite

## Activity

A change of the setup of a sprite, at the request of the engineer: "yes `.vendor/agents-playbook/src/system/AGENTS.md` is important". A test session of Claude Code in the sprite `mcp-essence-harness-sandbox` reported that the system rules of the playbook reached it only as files, and not as instructions.

## Work products

- `sprite-setup.sh` — changed: the step A3, which adds `@<clone>/.vendor/agents-playbook/src/system/AGENTS.md` to `~/.claude/CLAUDE.md` once
- `AGENTS.md` — changed: step 2 of the setup in the Rationale of the sprite section

## Agent skills

- simplified-technical-english
- version-control

## Decisions

- The import is in `~/.claude/CLAUDE.md` of the sprite, and not in the `CLAUDE.md` of the repository. On the computer of the engineer, the global `CLAUDE.md` already loads the playbook, and an import in the repository would load it twice there.
- The step is A3, the number that the script did not use, between the git identity and the dependencies.
- The step adds the line only if `~/.claude/CLAUDE.md` does not hold it, so that each run of the script can occur again with no harm. It keeps each other line of the file.
- The step stops the script if the clone has no `.vendor/agents-playbook/src/system/AGENTS.md`, because a session with no playbook applies no playbook rule.
- The check, in the sprite: the script ran two times, and `~/.claude/CLAUDE.md` then held the import once. A new `claude -p` session named `/home/sprite/.claude/CLAUDE.md` and the import as loaded at the start, and gave the title of each of the six playbook rules. The script was then restored in the clone of the sprite, so that the work branch `feat/count-the-resolutions-of-a-link` holds no change of this activity.
