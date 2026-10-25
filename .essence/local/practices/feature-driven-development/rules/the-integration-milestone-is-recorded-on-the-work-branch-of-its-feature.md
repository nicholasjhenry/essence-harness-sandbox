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

- **feature**, **feature record**, **build**, **test command** — the vocabulary of this practice
- **integration milestone** — the `a-feature-reaches-its-milestones-in-order` rule
- **branch of the build**, **test command of the build** — the `the-build-is-stated-in-a-local-rule` rule
- **work branch**, **squash merge**, **pull request** — the vocabulary of the version-control practice, in `practices/version-control/`
- **engineer** — `language/vocabulary.md`

## Examples

The examples use a build on `main`, with `mix test` as its test command.

- ❌ The engineer approves the pull request of a feature. The agent squash-merges it, and records the integration milestone on a new work branch with a pull request of its own — breaks R1. The engineer then reviews a second time for one date.
- ❌ The agent records the integration milestone on the work branch, and `main` holds a commit that the work branch does not hold — breaks R2. The test command then passed on a set of files that `main` does not hold after the merge.
- ❌ The agent records the integration milestone on the work branch before the engineer requests the merge — breaks R2. The record then states a merge that the engineer did not decide.
- ❌ The agent records the integration milestone, pushes the work branch, and leaves it unmerged — breaks R3. The record then states a merge that did not occur.
- ✅ The engineer approves the pull request of a feature. The agent merges `main` into the work branch, and `mix test` passes on it. The agent writes the date of the integration milestone in the feature record, and commits it on the work branch. Then it squash-merges the work branch into `main`, in the same activity.

## Rationale

The integration milestone states two facts: the code of the feature is in the branch of the build, and the test command of the build passes there. R3 of the `the-build-is-stated-in-a-local-rule` rule requires the merge. This rule decides when the milestone is recorded: on the work branch, before the merge.

A record after the merge is a new unit of work on the branch of the build. It then needs a work branch and a merge of its own, and the engineer reviews it a second time.

A work branch that holds each commit of the branch of the build differs from that branch only by its own commits. Its squash merge then gives the branch of the build the same files as the work branch. The test command that passes on the work branch therefore passes on the branch of the build after the merge. R3 makes the record and the merge one activity, so the record never states a merge that did not occur.

The squash commit on the branch of the build holds the code of the feature and the record of its integration together. The engineer approves both in the pull request of the feature.

## Related

- the the-build-is-stated-in-a-local-rule rule — the branch and the test command of the build, and the merge that the milestone requires
- the a-feature-reaches-its-milestones-in-order rule — the integration milestone, after the code inspection milestone
- the a-work-branch-is-squash-merged-at-the-request-of-the-engineer rule, in `practices/version-control/` — the request of the engineer that the merge waits for

---

Authored by Nicholas Henry on Sun Oct 25 2026 at 11:14:20 AM EDT
