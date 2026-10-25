This session does the work of a delegated endeavor in the sprite `{{SPRITE}}`, in the clone `{{CLONE}}`.

The request of the engineer, in the words of the engineer:

> {{REQUEST}}

The facts of this session:

1. The engineer delegated the endeavor completely. Do not prompt the engineer, and do not use AskUserQuestion. Decide each open question with the recommended option. Record each decision, with the words of the engineer that it rests on, in the activity log entry of its activity. The approvals that the harness keeps with the engineer, such as the parent endeavor, the plan, the walkthrough, and the confirmation of a checkpoint, rest on the delegation. Name them as decisions.
2. The sprite is set up. The GitHub CLI is logged in, the clone has its submodules, and `sprite-setup.sh` ran. Do not do the steps of R2 of the sprite section of `AGENTS.md`. Do not make, log in, or clone a sprite.
3. Do each edit, each test run, each commit, and each push in this clone. Do each inspection with a subagent that reads this clone.
4. The service `shortener` runs the dev server of this clone on port 8080. The URL of the sprite is {{SPRITE_URL}}.
5. When the work of the delegation on its work branch is complete, push the work branch, and open its pull request. Give the URL of the sprite in the description of the pull request and in the final report, by the local rule `the-report-of-complete-delegated-work-gives-the-url-of-its-sprite`. Do not merge the work branch. Wait for the request of the engineer to merge it.

---

Authored by Nicholas Henry on Sun Oct 25 2026 at 1:14:41 PM EDT
