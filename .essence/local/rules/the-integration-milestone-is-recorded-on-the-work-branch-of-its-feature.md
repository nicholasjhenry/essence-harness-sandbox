# The integration milestone is recorded on the work branch of its feature, before the squash merge

## Rules

- **R1.** The integration milestone of a feature must be recorded on the work branch of the feature, when the engineer requests the merge of that work branch.
  - **Classification:** behavioral
  - **Enforced:** when the engineer requests the merge of the work branch of a feature
  - **Violation response:** the agent does not merge the work branch. It records the integration milestone on the work branch first, by R2.
- **R2.** The integration milestone of a feature may be recorded on its work branch only if all of the following are true:
  - the engineer requested the merge of the work branch
  - the work branch holds each commit of the branch of the build
  - the test command of the build passes on the work branch, after the last commit of the code
  - **Classification:** behavioral
  - **Enforced:** when the integration milestone is recorded on a work branch
  - **Violation response:** the agent removes the record. It merges the branch of the build into the work branch, runs the test command of the build, and records the milestone again.
- **R3.** The work branch of a feature must be squash-merged into the branch of the build in the activity that records its integration milestone.
  - **Classification:** behavioral
  - **Enforced:** when the integration milestone is recorded on a work branch
  - **Violation response:** the agent squash-merges the work branch, or removes the record of the milestone.
- **R4.** The record of the integration milestone need not have a pull request of its own.
  - **Classification:** advisory
  - **Enforced:** nowhere. R4 is an advisory statement.
  - **Violation response:** none.

## Facts

- **integration milestone**, **feature**, **build**, **test command** — the vocabulary of the feature-driven-development practice, in `.essence/local/practices/feature-driven-development/`
- **branch of the build**, **test command of the build** — the `the-build-is-the-main-branch` local rule: `main` and `mix test`
- **work branch**, **squash merge** — the vocabulary of the version-control practice, in `.essence/system/practices/version-control/`
- **engineer** — `.essence/system/language/vocabulary.md`

## Examples

- ❌ The engineer approves the pull request of a feature. The agent squash-merges it, and records the integration milestone on a new work branch with a pull request of its own — breaks R1. The engineer then reviews a second time for one date.
- ❌ The agent records the integration milestone on the work branch, and `main` has a commit that the work branch does not hold — breaks R2. The test command then passed on a set of files that `main` does not have after the merge.
- ❌ The agent records the integration milestone on the work branch before the engineer requests the merge — breaks R2. The record then states a merge that the engineer did not decide.
- ❌ The agent records the integration milestone, pushes the work branch, and leaves it unmerged — breaks R3. The record then states a merge that did not occur.
- ✅ The engineer approves the pull request of a feature. The agent merges `main` into the work branch, and `mix test` passes on it. The agent writes the date of the integration milestone in the feature record, with its activity log entry, and commits them on the work branch. Then it squash-merges the work branch into `main`, in the same activity.

## Rationale

The integration milestone states two facts: the code of the feature is in the branch of the build, and the test command of the build passes there. The feature-driven-development practice records the milestone after the merge, in R3 of its `the-build-is-stated-in-a-local-rule` rule and in its `a-feature-reaches-its-milestones-in-order` rule. A record after the merge is a new unit of work on `main`, and it then needs a work branch and a merge of its own.

This rule is applied in place of the time of the record in those two rules, by the `a-local-rule-is-applied-in-place-of-a-system-rule-it-conflicts-with` rule. The two facts of the milestone do not change.

A work branch that holds each commit of `main` differs from `main` only by its own commits. Its squash merge then gives `main` the same files as the work branch. The test command that passes on the work branch therefore passes on `main` after the merge. R3 makes the record and the merge one activity, so the record never states a merge that did not occur.

The squash commit on `main` holds the code of the feature and the record of its integration together. The engineer approves both in the pull request of the feature.

## Related

- the the-build-is-the-main-branch rule — the branch and the test command of the build
- the a-reviewer-overrides-entry-criteria-and-delegated-work-ends-in-a-pull-request rule — the request of the engineer to merge a delegated work branch

---

Authored by Nicholas Henry on Sun Oct 25 2026 at 11:11:19 AM EDT
