# A feature is added or amended in its feature record

## Rules

- **R1.** A feature may be added to the feature list after the feature list is made.
  - **Classification:** advisory
  - **Enforced:** nowhere. R1 is an advisory statement.
  - **Violation response:** none.
- **R2.** The milestone dates of a feature record must be cleared when the name of its feature changes after its domain walkthrough milestone.
  - **Classification:** behavioral
  - **Enforced:** when the name of a feature changes
  - **Violation response:** the agent clears the milestone dates of the feature record.
- **R3.** A feature record must be renamed when the name of its feature changes.
  - **Classification:** behavioral
  - **Enforced:** when the name of a feature changes
  - **Violation response:** the agent renames the feature record by its new feature name.

## Facts

- **feature**, **feature list**, **feature record**, **milestone** — the vocabulary of this practice
- **milestone date** — the date on which a feature reached a milestone, in R3 of the `each-feature-is-recorded-in-a-feature-record` rule

## Examples

- ❌ A renamed feature keeps its milestone dates — breaks R2. The record then says that a design exists for a function that nobody designed.
- ❌ A feature is renamed, and its feature record keeps the old file name — breaks R3.
- ❌ A new feature is added to the record of another feature — breaks R1 of the each-feature-is-recorded-in-a-feature-record rule. The record then holds two features.
- ✅ A new feature gets a new feature record, with a feature set, a major feature set, and the plan position of its feature set.

## Rationale

The feature list changes as the customer learns what it needs. A change in one record changes the state of one feature and no other.

A new feature is a new feature record. It takes a feature set, a major feature set, and the plan position of its feature set.

A new name is a new result or a new concept. The walkthrough and the design of the old name do not apply to it. With no milestone dates, the feature is `Planned` again, and the design by feature process starts again.

## Related

- the each-feature-is-recorded-in-a-feature-record rule — the record that is added or amended
- the a-feature-is-named-by-the-feature-template rule — the name that changes

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 6:58:29 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:14:10 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:18:12 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:30:00 AM EDT
