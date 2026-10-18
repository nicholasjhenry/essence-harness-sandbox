# Each feature is recorded in a feature record

## Rules

- **R1.** A feature must be recorded in its own feature record in `.essence/local/work-products/features/`.
  - **Classification:** structural
  - **Enforced:** when a feature is added to the feature list
  - **Violation response:** the agent writes the feature record of the feature.
- **R2.** The file name of a feature record must be the name of its feature, in lower case, with a dash in place of each space, and `.md` at the end.
  - **Classification:** structural
  - **Enforced:** when a feature record is written or renamed
  - **Violation response:** the agent renames the file.
- **R3.** A feature record must hold each of the following:
  - the name of the feature, as its title
  - the major feature set of the feature
  - the feature set of the feature
  - the plan position of the feature
  - the date on which the feature reached each milestone
  - the design of the feature, after the design milestone
  - **Classification:** structural
  - **Enforced:** when a feature record is written or changed
  - **Violation response:** the agent adds the missing item.
- **R4.** A feature record must be amended when its feature reaches a milestone.
  - **Classification:** behavioral
  - **Enforced:** when a feature reaches a milestone
  - **Violation response:** the agent writes the date of the milestone in the feature record.
- **R5.** A feature record must not name the endeavor that tracks its feature.
  - **Classification:** structural
  - **Enforced:** when a feature record is written or changed
  - **Violation response:** the agent removes the name of the endeavor. The requirements document of the endeavor lists the record.
- **R6.** A feature record must not record the state of its feature.
  - **Classification:** structural
  - **Enforced:** when a feature record is written or changed
  - **Violation response:** the agent removes the state, and computes it from the milestone dates.

## Facts

- **feature**, **feature record**, **feature set**, **major feature set**, **plan position**, **milestone**, **design of a feature**, **state of a feature** — the vocabulary of this practice
- **endeavor** — `language/vocabulary.md`

## Examples

- ❌ A feature exists only in a conversation — breaks R1. The next session does not know it.
- ❌ One feature record holds two features — breaks R1. The record then holds the milestones of two features.
- ❌ The record of "Calculate the total of a sale" is named `sale-total.md` — breaks R2.
- ❌ A feature record holds the line "**State:** Designed" — breaks R6. The record then holds a second copy of what its milestone dates compute, and the two copies differ in time.
- ✅ `.essence/local/work-products/features/calculate-the-total-of-a-sale.md`:

  ```markdown
  # Calculate the total of a sale

  **Major feature set:** Product sales management
  **Feature set:** Making a product sale
  **Plan position:** 1

  ## Milestones

  | Milestone | Date reached |
  |---|---|
  | domain walkthrough | 2026-10-19 |
  | design | 2026-10-20 |
  | design inspection | 2026-10-21 |
  | code | |
  | code inspection | |
  | integration | |

  ## Design

  A sale gets its total from the sum of the line totals of its sale lines.
  ```

## Rationale

One record for each feature lets the agent add or amend a feature alone. Each record keeps the history of its own feature.

The feature records are the feature list. A list of the files in `.essence/local/work-products/features/` is a list of the features.

The requirements document of an endeavor names the features it tracks. The record stays in `.essence/local/work-products/features/` for the life of its feature.

The state of a feature is computed, and not recorded. The milestone dates of the feature record and the requirements documents give the state.

## Related

- the the-state-of-a-feature-is-the-last-milestone-it-reached rule — the state that the record gives
- the a-feature-is-added-or-amended-in-its-feature-record rule — how the list changes

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 6:58:29 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:04:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:14:10 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:30:00 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:12:38 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:23:48 PM EDT
