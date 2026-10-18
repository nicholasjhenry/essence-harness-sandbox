# A feature reaches its milestones in order

## Rules

- **R1.** A feature must reach each milestone only after it reached each milestone before it in the following list:
  1. domain walkthrough
  2. design
  3. design inspection
  4. code
  5. code inspection
  6. integration
  - **Classification:** behavioral
  - **Enforced:** before a feature starts a milestone, from the milestone dates of its feature record
  - **Violation response:** the agent stops the work on the milestone, and takes the feature to the first milestone it did not reach.

## Facts

- **feature**, **milestone**, **feature record**, **build**, **test command**, **inspector** — the vocabulary of this practice

## Examples

- ❌ The code of a feature is written before the design inspection — breaks R1. A defect in the design is then found in the code, where it costs more.
- ❌ The code of a feature is merged before the code inspection — breaks R1. The build then holds code that nobody but its author read.
- ✅ The feature record shows a date for the design inspection. The agent then starts the code.

## Rationale

Each milestone is a check on the one before it. A feature that skips a milestone skips that check.

Each milestone is a fact about the feature:

| Milestone | The feature reaches it when |
|---|---|
| domain walkthrough | the engineer walked through the part of the domain that the feature uses |
| design | the design of the feature is in its feature record |
| design inspection | an inspector accepted the design |
| code | the code and the unit tests of the feature are written, and each unit test passes |
| code inspection | an inspector accepted the code |
| integration | the code is merged into the branch of the build, and the test command of the build passes on it |

The first three milestones are in the design by feature process. The last three are in the build by feature process.

## Related

- the an-inspection-is-made-by-someone-other-than-the-author rule — the two inspections
- the each-milestone-carries-a-fixed-weight rule — the weight of each milestone
- the the-build-is-stated-in-a-local-rule rule — the branch and the test command of the integration milestone

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:16:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
