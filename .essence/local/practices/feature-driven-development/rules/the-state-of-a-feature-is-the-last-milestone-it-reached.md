# The state of a feature is the last milestone it reached

## Rules

- **R1.** The state of a feature that reached no milestone must be considered `Listed` if any of the following is true:
  - the feature has no plan position
  - the feature is in the backlog
  - **Classification:** definitional
  - **Enforced:** when the state of a feature is computed or reported
  - **Violation response:** the agent computes the state again from the feature record and the requirements documents.
- **R2.** The state of a feature must be considered `Planned` if all of the following are true:
  - the feature has a plan position
  - a requirements document lists the feature record of the feature
  - the feature reached no milestone
  - **Classification:** definitional
  - **Enforced:** when the state of a feature is computed or reported
  - **Violation response:** the agent computes the state again from the feature record and the requirements documents.
- **R3.** The state of a feature must be considered the state that the last milestone it reached gives, in the following table, if it reached a milestone.

  | Last milestone reached | State of the feature |
  |---|---|
  | domain walkthrough | `Walked Through` |
  | design | `Designed` |
  | design inspection | `Design Inspected` |
  | code | `Coded` |
  | code inspection | `Code Inspected` |
  | integration | `Integrated` |

  - **Classification:** definitional
  - **Enforced:** when the state of a feature is computed or reported
  - **Violation response:** the agent computes the state again from the milestone dates of the feature record.

## Facts

- **state of a feature**, **milestone**, **plan position**, **backlog**, **feature record** — the vocabulary of this practice
- **requirements document** — `language/vocabulary.md`

## Examples

- ❌ The state of a feature that reached the design milestone is reported as "nearly done" or "in progress" — breaks R3. The reader cannot tell what is complete.
- ❌ The state of a feature is reported as "design inspection" — breaks R3. The name of an event does not say what is true now.
- ❌ A feature record holds its state — breaks R6 of the each-feature-is-recorded-in-a-feature-record rule. The written state then differs from the milestone dates when the work changes.
- ✅ A feature record has a date for the design inspection and no date for the code. The state of the feature is `Design Inspected`.
- ✅ A feature reached no milestone, and a requirements document lists its record. The state of the feature is `Planned`.

## Rationale

A state that the milestones compute is a state that every reader reads the same way. A state that nobody writes cannot go out of date.

A milestone is an event, and a state is what is true after it. The state names the condition of the feature. A feature in the state `Design Inspected` has an accepted design and no code.

A `Planned` feature has an approved plan. A requirements document lists a feature record only after the engineer approved the plan of its feature set.

The state is computed, and not recorded. The milestone dates of the feature record give it. Before the first milestone, the requirements documents give it.

## Related

- the a-feature-reaches-its-milestones-in-order rule — the milestones that give a state
- the a-feature-set-is-planned-before-its-features-are-designed rule — the approval that comes before the list
- the each-feature-is-recorded-in-a-feature-record rule — the record that gives the state

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 6:58:29 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:04:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:14:10 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:15:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:20:04 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:30:00 AM EDT
