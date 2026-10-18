# A feature list is made from a domain model

## Rules

- **R1.** A feature list must be made from the domain model of its software system.
  - **Classification:** structural
  - **Enforced:** when the feature list is built or changed
  - **Violation response:** the agent stops the feature list, and makes the domain model first.

## Facts

- **feature list**, **domain model** — the vocabulary of this practice
- **software system**, **domain vocabulary** — `language/vocabulary.md`

## Examples

- ❌ A feature list made from screens or tasks — breaks R1. The features then follow the plan of the work and not the domain.
- ❌ A feature list made from a model of tables and services — breaks R1. That model is of the implementation, and it changes for reasons the domain does not have.
- ✅ The domain vocabulary defines "sale". The domain model records the properties and the associations of a sale. The feature list then holds "Calculate the total of a sale".

## Rationale

The domain model comes first. The engineer walks through each part of the domain. The agent defines each concept in the domain vocabulary, in `.essence/local/work-products/vocabulary.md`. The agent records the properties and the associations of each concept in the model, in `.essence/local/work-products/domain-model.md`, with a note for each decision. Then the agent divides the domain into features.

The domain vocabulary gives the feature list its words, and the model gives it its structure. The concept of each feature is defined in the domain vocabulary, and is in the model. The model does not define a concept again. A subject area of the model is a major feature set.

A feature names an action on a concept of the domain. Without the model, two features name one concept with two words. Nobody can then see that they touch the same thing.

## Related

- the a-feature-is-named-by-the-feature-template rule — the concept that comes from the model
- the a-feature-belongs-to-one-feature-set-of-one-major-feature-set rule — the subject areas that come from the model
- the the-terms-of-a-domain-are-defined-in-the-domain-vocabulary rule — where each concept is defined

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:18:12 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:58:04 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:53:45 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:41:36 PM EDT
