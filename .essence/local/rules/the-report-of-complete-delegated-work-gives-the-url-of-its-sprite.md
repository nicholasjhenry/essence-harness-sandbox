# The report and the pull request of complete delegated work give the URL of its sprite

## Rules

- **R1.** The report of the work of a delegation must give the URL of the sprite of the endeavor if all of the following are true:
  - the work of the delegation on its work branch is complete
  - the work of the endeavor is done in a sprite
  - **Classification:** behavioral
  - **Enforced:** when the agent reports the pull request of the work branch to the engineer
  - **Violation response:** the agent gives the URL of the sprite to the engineer in a new report.
- **R2.** The URL of a sprite in a report or in the description of a pull request must be the `url` that the Fly MCP server or the `sprite` CLI gives for the sprite.
  - **Classification:** structural
  - **Enforced:** when the URL of a sprite is written in a report or in the description of a pull request
  - **Violation response:** the agent reads the URL of the sprite again, and writes it again.
- **R3.** The description of a pull request of the work branch of a delegation must give the URL of the sprite of the endeavor if the work of the endeavor is done in a sprite.
  - **Classification:** structural
  - **Enforced:** when the pull request is opened, and when the agent reports the work of the delegation while the pull request exists
  - **Violation response:** the agent edits the description of the pull request that exists, and adds the URL of the sprite.

## Facts

- **delegation**, **endeavor**, **engineer**, **agent** — `.essence/system/language/vocabulary.md`
- **complete**, for the work of a delegation on a work branch — R7 of the `a-reviewer-overrides-entry-criteria-and-delegated-work-ends-in-a-pull-request` rule, in `.essence/system/rules/`
- **pull request**, **work branch** — the vocabulary of the version-control practice, in `.essence/system/practices/version-control/`
- **sprite** — the second section of `AGENTS.md`
- **report of the work of a delegation** — the Rationale of this rule

## Examples

- ❌ The agent reports the pull request of a delegated endeavor that it developed in the sprite `mcp-essence-harness-sandbox`, and gives no URL of the sprite — breaks R1. The engineer then cannot open the app to try the work before the merge.
- ❌ The agent writes `https://mcp-essence-harness-sandbox.fly.dev` from memory — breaks R2. The URL of a sprite holds a suffix that the agent cannot guess.
- ❌ The agent opens the pull request of a delegated endeavor that it developed in a sprite, and its description gives no URL of the sprite — breaks R3. A reviewer who reads only the pull request then cannot find the app of the work branch.
- ✅ The description of the pull request holds the line `The app of this branch runs in the sprite: https://mcp-essence-harness-sandbox-wr6.sprites.app`.
- ✅ The agent ends the report with the pull request and the URL:

  ```
  The pull request is https://github.com/nicholasjhenry/essence-harness-sandbox/pull/4. The app of the work branch runs at https://mcp-essence-harness-sandbox-wr6.sprites.app. Merge the pull request, or request changes.
  ```

- ✅ The agent reports the pull request of a delegated endeavor that it did in the local repository, and gives no URL of a sprite. R1 does not apply.

## Rationale

The report of the work of a delegation is the message in which the agent gives the pull request to the engineer, and waits. The engineer reviews the work there, and decides the merge.

The service `shortener` of the sprite runs the dev server of the work branch, and the proxy of the sprite routes the URL of the sprite to it. The URL lets the engineer try the work in a browser before the merge. R3 puts the URL in the pull request too, because the pull request stays after the session ends, and the report does not. A pull request that was opened before the URL was given gets the URL in an edit of its description. A sprite whose access is private asks the engineer to log in first.

The URL holds a suffix that Fly gives the sprite when it makes it. R2 therefore takes the URL from the Fly MCP server or the `sprite` CLI, and not from the name of the sprite.

## Related

- the a-reviewer-overrides-entry-criteria-and-delegated-work-ends-in-a-pull-request rule, in `.essence/system/rules/` — the pull request that the report gives
- the second section of `AGENTS.md` — the sprite and its service

---

Authored by Nicholas Henry on Sun Oct 25 2026 at 11:52:10 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 12:32:27 PM EDT
