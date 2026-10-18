# The build is the main branch, and its test command is mix test

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

- **build**, **test command**, **feature**, **milestone** — the vocabulary of the feature-driven-development practice, in `.essence/local/practices/feature-driven-development/`
- **integration milestone** — the `a-feature-reaches-its-milestones-in-order` rule of the feature-driven-development practice

## Examples

- ❌ The code of a feature is merged into a work branch, and the integration milestone is recorded — breaks R1. The build then does not hold the feature.
- ❌ The agent runs `mix test test/shortener` on `main`, and records the integration milestone — breaks R2. The command does not run each test of the build.
- ✅ The code of a feature is squash-merged into `main`, and `mix test` passes on `main`.

## Rationale

The software system keeps its code on `main`, which is the default branch of the repository. The version-control practice squash-merges each work branch into `main`.

The software system is a Mix project. `mix test` runs each ExUnit test of the project.

## Related

- the the-build-is-stated-in-a-local-rule rule, in `.essence/local/practices/feature-driven-development/` — the rule that this rule meets

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:07:33 PM EDT
