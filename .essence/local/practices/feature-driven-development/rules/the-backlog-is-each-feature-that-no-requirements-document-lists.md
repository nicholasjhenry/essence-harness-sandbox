# The backlog is each feature that no requirements document lists

## Rules

- **R1.** A feature must be considered in the backlog if no requirements document lists its feature record.
  - **Classification:** definitional
  - **Enforced:** when the backlog is found, and when the state of a feature is computed
  - **Violation response:** the agent computes the backlog again from the requirements documents.

## Facts

- **feature**, **backlog**, **feature record** — the vocabulary of this practice
- **requirements document** — `language/vocabulary.md`

## Examples

- ❌ The agent takes the backlog from a second list, and not from the requirements documents — breaks R1. The second list then differs from the requirements documents.
- ❌ A feature record is moved to show that an endeavor takes the feature — breaks R1 of the each-feature-is-recorded-in-a-feature-record rule. The record then loses its place in the feature list.
- ✅ An endeavor takes a feature. The agent lists the feature record in the requirements document of the endeavor, and the record stays where it is.

## Rationale

A backlog that the requirements documents compute is always the same as the work that no endeavor took.

The backlog is a part of the feature list, and not a place. A feature record stays in `.essence/local/work-products/features/` when an endeavor takes the feature, and when the endeavor gives it up. Only the list in the requirements document changes.

A new feature enters the backlog. The plan by feature process takes features out of the backlog when it lists them in the requirements document of an endeavor.

To find the backlog, the agent lists each feature record. Then it removes each record that a requirements document lists.

## Related

- the a-requirements-document-lists-at-least-one-feature rule — the documents that take features out of the backlog
- the each-feature-is-recorded-in-a-feature-record rule — where each record stays

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 8:04:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:20:04 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:12:38 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:23:48 PM EDT
