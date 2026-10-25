# Start the Claude Code session of a delegated endeavor in a sprite

## Activity

A change of the way of working with a sprite, at the request of the engineer: "I would like the delegation of an endeavor inside a sprite to start a session with Claude Code. I would then attach and authenticate", and "it should have the correct prompt".

## Work products

- `sprite-agent.sh` — made: the start script
- `sprite-agent-prompt.md` — made: the prompt template
- `AGENTS.md` — changed: the title of the sprite section, R4, R5, and R6, three facts, four examples, and two paragraphs of the Rationale

## Agent skills

- rule-speak
- simplified-technical-english
- version-control

## Decisions

- The prompt is a template file in the repository, and the start script fills it in. Each session then gets the same facts, and a change of the prompt is a change that git records.
- The prompt states five facts: the delegation with no prompt, the sprite that is set up, the clone as the one place of the work, the dev server and the URL of the sprite, and the pull request with the URL and no merge. These are the decisions of this session that the session in the sprite cannot read: the memory "delegated endeavor means no prompts", the memory "sprite work is edited in the sprite", and the local rule of the URL of the sprite.
- The request goes into the prompt in the words of the engineer, as a quote, by R5.
- The start script needs the clone clean and on `main`, because the session makes its own work branch from `main`.
- The session is a TTY session of `claude`, and not `claude -p`. A TTY session keeps running after its client ends, and the engineer can attach to it, log in, and type in it.
- The rules apply to a delegated endeavor in a sprite only. An endeavor that is not delegated needs the engineer during its work, in this session.
- The checks: `./sprite-agent.sh -n` printed the prompt with a request of four lines in the quote, and with no placeholder. With the clone on `feat/count-the-resolutions-of-a-link`, the script stopped with "the clone /home/sprite/app is not on main". With the clone on `main`, the script started session 6735, ended its own client, and printed the attach command. The session was already logged in, from the login of the engineer in the test session 4333, and wrote `ready` to `/tmp/sprite-agent-test.txt` with no change to the clone. The agent then ended sessions 4333 and 6735, removed the test file, and put the clone back on `feat/count-the-resolutions-of-a-link`.
