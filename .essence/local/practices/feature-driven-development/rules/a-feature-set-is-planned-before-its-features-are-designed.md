# A feature set is planned before its features are designed

## Rules

- **R1.** The domain walkthrough of a feature may start only if all of the following are true:
  - the feature set of the feature has a plan position
  - a requirements document lists the feature record of the feature
  - **Classification:** behavioral
  - **Enforced:** when the domain walkthrough of a feature starts
  - **Violation response:** the agent does not start the walkthrough. The agent plans the feature set first.
- **R2.** The plan position of a feature must be the plan position of its feature set.
  - **Classification:** structural
  - **Enforced:** when a plan position is written in a feature record
  - **Violation response:** the agent writes the plan position of the feature set in the feature record.
- **R3.** A feature record may be listed in a requirements document only if the engineer approved the plan of its feature set.
  - **Classification:** behavioral
  - **Enforced:** when a feature record is listed in a requirements document
  - **Violation response:** the agent removes the record from the list, and asks the engineer to approve the plan.

## Facts

- **feature**, **feature set**, **plan position**, **feature record** — the vocabulary of this practice
- **domain walkthrough** — a milestone of the `a-feature-reaches-its-milestones-in-order` rule
- **requirements document**, **engineer** — `language/vocabulary.md`

## Examples

- ❌ The agent starts the walkthrough of a feature whose feature set has no plan position — breaks R1. The work then follows what is of interest, not what the customer needs first.
- ❌ A feature record holds the plan position 3, and its feature set has the plan position 2 — breaks R2. The plan then has two places for one set.
- ❌ The agent lists a feature record before the engineer approved the plan — breaks R3. The feature is then `Planned` on a plan that nobody approved.
- ✅ The engineer approves the plan. The agent then lists each record of the feature set in the requirements document of the endeavor.

## Rationale

A plan by feature set states the order in which the customer gets each feature set. Each feature record holds the plan position of its feature set, so the next feature is visible in its own record.

The plan holds no date. The pace of the work of an agent is not a pace in months, and no rule compares the progress with a date.

The plan puts the feature sets in order. The order follows the dependencies between the feature sets, their risk, and their value to the customer. The engineer approves the plan.

The approval comes before the list. A requirements document lists only the features of an approved plan. A feature that the list holds is then `Planned`, and its plan is approved. The activity log entry of the plan by feature activity records the approval.

The agent plans by feature in these steps:

1. Put the feature sets in order.
2. Give each feature set its plan position.
3. Write the plan position in each feature record of the set.
4. Ask the engineer to approve the plan.
5. When the engineer approves it, list each record in the requirements document of the endeavor.

## Related

- the a-feature-reaches-its-milestones-in-order rule — the domain walkthrough this rule comes before
- the the-state-of-a-feature-is-the-last-milestone-it-reached rule — the `Planned` state

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 6:58:29 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:04:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:15:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:20:37 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:30:00 AM EDT
