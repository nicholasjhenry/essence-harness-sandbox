# The build is stated in a local rule

## Rules

- **R1.** A software system that applies this practice must state its build in a rule in `.essence/local/rules/`.
  - **Classification:** structural
  - **Enforced:** when the practice is installed, and before a feature reaches the integration milestone
  - **Violation response:** the agent asks the engineer for the branch and the test command of the build, and writes them as a local rule.
- **R2.** The rule of the build must state each of the following:
  - the branch of the build
  - the test command of the build
  - **Classification:** structural
  - **Enforced:** when the rule of the build is written or changed
  - **Violation response:** the agent asks the engineer for the missing item, and adds it to the rule.
- **R3.** The code of a feature must be merged into the branch of the build when the feature reaches the integration milestone.
  - **Classification:** behavioral
  - **Enforced:** when the code of a feature is merged
  - **Violation response:** the agent does not record the integration milestone. It merges the code into the branch of the build, and runs the test command of the build there.

## Facts

- **build**, **test command**, **milestone**, **feature** — the vocabulary of this practice
- **software system** — `language/vocabulary.md`
- **local rule** — the `a-local-rule-is-applied-in-place-of-a-system-rule-it-conflicts-with` rule, in `rules/`

## Examples

- ❌ A feature is merged, and no local rule states the build — breaks R1. Each session then merges to the branch it guesses, and runs the tests it finds.
- ❌ The rule of the build names the branch, and no test command — breaks R2.
- ✅ `.essence/local/rules/the-build-is-the-main-branch.md`:

  ```markdown
  # The build is the main branch

  ## Rules

  - **R1.** The branch of the build must be `main`.
    - **Classification:** definitional
    - **Enforced:** when a feature reaches the integration milestone
    - **Violation response:** the agent merges the code of the feature into `main`.
  - **R2.** The test command of the build must be `mix test`.
    - **Classification:** definitional
    - **Enforced:** when a feature reaches the integration milestone
    - **Violation response:** the agent runs `mix test` on `main`.

  ## Facts

  - **build**, **test command** — the vocabulary of the feature-driven-development practice

  ## Examples

  - ❌ The code of a feature is merged into `develop` — breaks R1.
  - ✅ The code of a feature is merged into `main`, and `mix test` passes on `main`.

  ## Rationale

  The software system keeps its code on `main`, and runs its tests with `mix test`.

  ## Related

  - the the-build-is-stated-in-a-local-rule rule — the rule that this rule meets
  ```

- ❌ The code of a feature is merged into a branch other than the branch of the build, and the integration milestone is recorded — breaks R3. The build then does not hold the feature.
- ✅ The agent merges the code of a feature into the branch that the local rule states, and runs the test command of the rule there.

## Rationale

The integration milestone is a fact only if each reader checks it on the same branch, with the same command.

The extension does not know the build of a software system. Each software system keeps its code on its own branch, and runs its tests with its own command. Its local rule states both.

A feature reaches the integration milestone on the branch of the build. Its code is merged into that branch, and the test command of the build passes on it. Before a feature reaches the integration milestone, the agent reads the rule of the build.

## Related

- the a-feature-reaches-its-milestones-in-order rule — the integration milestone
- the a-local-rule-is-applied-in-place-of-a-system-rule-it-conflicts-with rule — where the local rule is

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 8:16:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:20:37 PM EDT
