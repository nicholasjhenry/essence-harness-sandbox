# Vendor the playbook and link the skills to it

## Activity

The agent added the playbook as a git submodule at `.vendor/agents-playbook`, and linked each skill in `.claude/skills/` to it, at the request of the engineer: "let's add the playbook to .vendor and update the `.clause/skills` symlinks". The activity belongs to no endeavor.

## Work products

- `.gitmodules` — changed: the submodule `.vendor/agents-playbook`
- `.vendor/agents-playbook` — made: a submodule at `74161cd`, on the branch `develop`
- `.claude/skills/elixir-core`, `elixir-ecto`, `elixir-livebook`, `elixir-otp`, `elixir-testing`, `elixir-typespec`, and `testing-names-given` — changed: each links to `../../.vendor/agents-playbook/src/skills/<name>`

## Agent skills

- version-control
- simplified-technical-english

## Decisions

- The path of the submodule is `.vendor/agents-playbook`, the name of its repository, as the harness is at `.vendor/essence-harness`.
- The submodule tracks `develop`, the default branch of `agents-playbook`.
- Each link is relative and stays in the repository. A clone with its submodules then has each skill on each machine. The link of `testing-names-given` was an absolute path to the computer of the engineer.
- The agent checked, before the change, that each of the seven skills is in `src/skills/` on `origin/develop`, and that the local playbook had no change that was not pushed.
- The directory `.claude/skills/fly-sprites` is empty and not tracked. The agent did not change it.
