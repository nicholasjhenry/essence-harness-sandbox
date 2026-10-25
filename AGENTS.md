# Essence Shortner — Agents

## The session starts with the initialization of the essence

### Rules

- **R1.** The start of a session in this repository must apply the `initialization-reads-the-system-and-local-essence-in-order` rule in `.essence/system/rules/`.
  - **Classification:** behavioral
  - **Enforced:** at the start of each session, before the first request is acted on
  - **Violation response:** the agent stops the work of the session. It reads the initialization rule, and then each item of its R1 in its order.

### Facts

- **system essence**, **local essence** — the `initialization-reads-the-system-and-local-essence-in-order` rule, in `.essence/system/rules/`

### Examples

- ❌ The agent acts on the first request, and reads the rules later — breaks R1. The agent then applies the rules from memory, or not at all.
- ✅ The agent reads `.essence/system/rules/initialization-reads-the-system-and-local-essence-in-order.md`. Then it reads each item of its R1 in its order, before the first request is acted on.

### Rationale

The agent applies only the rules that it has read. This file is the only file that the agent reads at the start of a session without a request.

This repository installs the harness. The system essence is in `.essence/system/`, and the local essence is in `.essence/local/`.

### Related

- the initialization-reads-the-system-and-local-essence-in-order rule — the read that the session starts with

## The work of an endeavor is done in a sprite only at the request of the engineer, and the sprite is set up first

### Rules

- **R1.** The work of an endeavor may be done in a sprite only if the engineer requests a sprite for the endeavor.
  - **Classification:** behavioral
  - **Enforced:** when the work of an endeavor is to start
  - **Violation response:** the agent does the work in the local repository, and does not start the work in a sprite.
- **R2.** A sprite must be set up by each of the following steps, in this order, before the work of an endeavor starts in it:
  1. The agent tells the engineer that 1Password asks for an approval, and then runs `./sprite-auth.sh <sprite>` on the computer of the engineer. The engineer approves the read in 1Password. The script logs the GitHub CLI of the sprite in, with the token at `op://Infrastructure/GitHub/credential` in 1Password. The token reads `essence-harness` and `agents-playbook`, and writes to `essence-harness-sandbox`.
  2. The agent clones the repository with its submodules, in the sprite: `git clone --recurse-submodules https://github.com/nicholasjhenry/essence-harness-sandbox ~/app`.
  3. The agent runs `./sprite-setup.sh --name "<name>" --email "<email>"` in `~/app`, with the `user.name` and the `user.email` of `git config` of the local repository.
  - **Classification:** behavioral
  - **Enforced:** when the work of an endeavor is to start in a sprite
  - **Violation response:** the agent stops the work in the sprite, and does each step that is not done, in order.
- **R3.** The GitHub token of a sprite must not be in a request or a tool call of the agent.
  - **Classification:** behavioral
  - **Enforced:** when the GitHub CLI of a sprite is logged in
  - **Violation response:** the agent stops, and asks the engineer to revoke the token and to log the sprite in again.

### Facts

- **sprite** — a Fly.io Sprite: a Linux machine with persistent storage and its own URL, which the `sprite` CLI and the Fly MCP server reach
- **endeavor**, **engineer**, **agent** — `.essence/system/language/vocabulary.md`
- **setup script** — `sprite-setup.sh`, in the root of the repository
- **login script** — `sprite-auth.sh`, in the root of the repository

### Examples

- ❌ The agent starts the work of a delegated endeavor in a sprite, and the engineer did not request a sprite — breaks R1. A delegation gives a reviewer the overrides, and not the selection of a sprite.
- ❌ The agent clones the repository with no `--recurse-submodules` — breaks R2. The links in `.essence/system/` and `.claude/skills/` then do not resolve, and `sprite-setup.sh` stops at its first check.
- ❌ The agent clones the repository before the engineer logs the sprite in — breaks R2. `essence-harness` and `agents-playbook` are private, so the clone gets no submodule.
- ❌ The agent runs `gh auth login --with-token` with the token in a tool call — breaks R3. The token is then in the transcript of the session.
- ❌ The agent prints `gh auth status` with its `Token:` line — breaks R3. The line shows the start of the token. The login script removes the line.
- ❌ The agent runs `./sprite-setup.sh` with no `--email` — breaks R2. The script stops. A new sprite has the global `user.email` `noreply@sprites.dev`, which no commit of the engineer takes.
- ✅ The engineer requests "develop it in a sprite". The agent tells the engineer to expect the approval of 1Password, and runs `./sprite-auth.sh mcp-essence-harness-sandbox`. The engineer approves it. The script pipes the token from 1Password to `gh auth login --with-token` and `gh auth setup-git` on the sprite. The agent then clones the repository with its submodules, and runs `./sprite-setup.sh --name "Nicholas Henry" --email "<email>"` in `~/app`.

### Rationale

A sprite holds the code of an endeavor while the code is written and tested, apart from the computer of the engineer. The engineer decides when an endeavor needs it, so R1 waits for a request. Each sprite starts with no clone, no git identity, no dependencies, and no service.

The setup script is in the repository, so it runs after the clone. The submodules are private, so the login comes before the clone. The script does each step that needs no secret:

1. It sets the git identity. Each commit uses it, and each provenance footer uses `git config user.name`.
2. It adds an import of `.vendor/agents-playbook/src/system/AGENTS.md` to `~/.claude/CLAUDE.md`. A Claude Code session in the sprite then applies the system rules of the playbook, as a session on the computer of the engineer does. The repository loads only this file, and the links in `.claude/skills/` give only the skills of the playbook.
3. It runs `mix setup`, which gets the dependencies, makes the database, and builds the assets.
4. It creates the service `shortener`, which runs the dev server on port 8080. The proxy of the sprite routes the URL of the sprite to that port. The service sets `PHX_HOST` to the host of the URL of the sprite. Each URL that the app makes, such as a short URL or a login link, is then a URL of the sprite, and not of `localhost`.

Each step of the script can run again with no harm. The engineer approves the login, because the token is a secret of the engineer. The agent runs the login script, and the approval of 1Password stops it until the engineer acts. The login script reads the token from 1Password, and pipes it to the sprite. The token is then in no argument of a command, in no local file, and in no tool call of the agent. The GitHub connector of the sprites does not replace the login. It gives the REST API of GitHub, and not `git clone` or `git push`.

### Related

- the a-document-ends-with-its-author-and-each-amendment rule — the `user.name` that each provenance footer takes

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 9:57:50 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 10:11:50 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 10:13:53 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 10:49:58 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 10:54:53 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 11:55:49 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 1:07:39 PM EDT
