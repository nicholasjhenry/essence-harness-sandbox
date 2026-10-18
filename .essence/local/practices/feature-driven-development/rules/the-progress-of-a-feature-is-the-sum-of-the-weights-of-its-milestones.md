# The progress of a feature is the sum of the weights of its milestones

## Rules

- **R1.** The progress of a feature must be computed as the sum of the weights of the milestones that the feature reached.
  - **Classification:** definitional
  - **Enforced:** when the progress of a feature is reported
  - **Violation response:** the agent computes the progress again from the feature record.
- **R2.** The progress of a feature set must be computed as the mean of the progress of its features.
  - **Classification:** definitional
  - **Enforced:** when the progress of a feature set is reported
  - **Violation response:** the agent computes the progress again from the feature records of the set.
- **R3.** The progress of a major feature set must be computed as the mean of the progress of the features of its feature sets.
  - **Classification:** definitional
  - **Enforced:** when the progress of a major feature set is reported
  - **Violation response:** the agent computes the progress again from the feature records of its feature sets.

## Facts

- **progress**, **weight**, **milestone**, **feature set**, **major feature set** — the vocabulary of this practice

## Examples

- ❌ "The feature is about 70 percent done" — breaks R1. The progress is an estimate, and the reader cannot check it.
- ✅ A feature at the design inspection milestone reached three milestones. Its progress is 1 + 40 + 3 = 44 percent.
- ✅ A feature set holds two features, at 44 percent and 100 percent. Its progress is 72 percent.

## Rationale

A progress that the feature records compute is the same for each reader. It changes only when a feature reaches a milestone.

The agent reads each feature record. It adds the weights of the milestones that each feature reached. Then it computes the mean for each feature set and each major feature set.

## Related

- the each-milestone-carries-a-fixed-weight rule — the weights
- the a-feature-belongs-to-one-feature-set-of-one-major-feature-set rule — the sets whose progress is computed

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
