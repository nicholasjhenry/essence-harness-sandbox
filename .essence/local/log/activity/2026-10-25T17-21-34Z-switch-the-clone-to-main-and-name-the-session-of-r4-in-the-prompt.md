# Switch the clone to main, and name the session of R4 in the prompt

## Activity

Two corrections of the start of the Claude Code session of a delegated endeavor in a sprite. The engineer approved the first one: "I'm not worried about the exsiting PR for the feature".

## Work products

- `sprite-agent.sh` — changed: a clean clone is switched to `main` and pulled, on each branch
- `sprite-agent-prompt.md` — changed: fact 3, which names the session as the session of R4

## Agent skills

- simplified-technical-english
- version-control

## Decisions

- The start script stops only if the clone has an uncommitted change. A clean clone on the branch of an earlier endeavor is switched to `main`, because that branch is pushed, and stays on GitHub. The engineer stated that the work branch of pull request 4 needs no protection in the clone.
- Fact 3 of the prompt tells the session that it is the session of R4, and that it does not run `sprite-agent.sh`. The session reads R4 in `AGENTS.md` too, and without fact 3 it could start a second session.
- The checks: the clone was clean, on `feat/count-the-resolutions-of-a-link`. The script switched it to `main` at `0f13557`, and started session 7074. The session wrote: "No. Fact 3 of the prompt forbids it: "Do not run sprite-agent.sh, and do not start a second session."" The clone stayed clean. The agent ended session 7074, and removed the test file. The clone stays on `main`.
