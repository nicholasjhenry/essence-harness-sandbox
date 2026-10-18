# A feature belongs to one feature set of one major feature set

## Rules

- **R1.** A feature must belong to exactly one feature set.
  - **Classification:** structural
  - **Enforced:** when a feature record is written or changed
  - **Violation response:** the agent puts the feature in the feature set of the business activity that the feature is a step of.
- **R2.** A feature set must belong to exactly one major feature set.
  - **Classification:** structural
  - **Enforced:** when a feature record is written or changed
  - **Violation response:** the agent names the subject area of the feature set as its major feature set.
- **R3.** The name of a feature set must take the form `<action>ing a(n) <concept>`.
  - **Classification:** structural
  - **Enforced:** when a feature set is named or renamed
  - **Violation response:** the agent renames the feature set by the form.
- **R4.** The name of a major feature set must take the form `<concept> management`.
  - **Classification:** structural
  - **Enforced:** when a major feature set is named or renamed
  - **Violation response:** the agent renames the major feature set by the form.

## Facts

- **feature**, **feature set**, **major feature set**, **feature record** — the vocabulary of this practice
- **concept** — the `a-concept-is-described-by-the-concept-speak-practice` rule, in `rules/`

## Examples

- ❌ A feature is in two feature sets — breaks R1. Its progress then counts twice.
- ❌ A feature set has no major feature set — breaks R2. The subject area of the feature set is not stated.
- ❌ A feature set named "Sales" — breaks R3. The name has no action and no concept.
- ❌ A major feature set named "Sales team" — breaks R4. The name is not a concept with "management".
- ✅ The three levels of the feature list, each named by its form:

  ```
  Product sales management          major feature set
    Making a product sale           feature set
      Calculate the total of a sale feature
  ```

## Rationale

The feature list has three levels. A major feature set is a subject area of the domain. A feature set is a business activity in it. A feature is a step of that activity.

A feature set and a major feature set are classifications, and not features. They have no state of their own. Their progress comes from their features.

One place for each feature makes the progress of each set the progress of its own features, and of no other. For each feature, the agent names the business activity that the feature is a step of. The agent names the subject area of that activity. The feature record holds both.

## Related

- the a-feature-is-named-by-the-feature-template rule — the template of the third level
- the the-progress-of-a-feature-is-the-sum-of-the-weights-of-its-milestones rule — the progress each set gets from its features

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:04:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
