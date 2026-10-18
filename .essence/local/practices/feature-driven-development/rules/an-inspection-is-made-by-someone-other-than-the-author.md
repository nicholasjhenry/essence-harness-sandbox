# An inspection is made by someone other than the author

## Rules

- **R1.** The inspector of the design of a feature must not be the author of the design.
  - **Classification:** structural
  - **Enforced:** when the design inspection of a feature starts, and when its milestone date is written
  - **Violation response:** the agent asks the engineer or a new agent session to inspect the design.
- **R2.** The inspector of the code of a feature must not be the author of the code.
  - **Classification:** structural
  - **Enforced:** when the code inspection of a feature starts, and when its milestone date is written
  - **Violation response:** the agent asks the engineer or a new agent session to inspect the code.

## Facts

- **inspector**, **inspection**, **design of a feature** — the vocabulary of this practice

## Examples

- ❌ The agent session that wrote the design of a feature inspects it — breaks R1. The author reads what they meant to write, and not what they wrote.
- ❌ The agent session that wrote the code of a feature inspects it — breaks R2.
- ✅ A new agent session reads only the feature record and the code, and inspects the code.

## Rationale

An inspection finds a defect only if the inspector reads the work without the intent of its author.

The inspector is the engineer, or an agent that did no work on the feature. An agent session that wrote the design or the code is its author. A new agent session that reads only the feature record and the code is not.

An inspection ends when the inspector accepts or rejects the work. A rejected design or code returns to its author. The feature stays at the milestone before the inspection. The agent records the milestone only when the inspector accepts.

## Related

- the a-feature-reaches-its-milestones-in-order rule — the design inspection and code inspection milestones

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
