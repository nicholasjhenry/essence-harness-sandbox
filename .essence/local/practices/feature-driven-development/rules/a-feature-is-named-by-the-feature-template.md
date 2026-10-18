# A feature is named by the feature template

## Rules

- **R1.** The name of a feature must take the form `<action> the <result> <by|for|of|to> a(n) <concept>`.
  - **Classification:** structural
  - **Enforced:** when a feature is named or renamed
  - **Violation response:** the agent renames the feature by the feature template.
- **R2.** The concept in the name of a feature must be a concept of the domain model.
  - **Classification:** structural
  - **Enforced:** when a feature is named or renamed
  - **Violation response:** the agent adds the concept to the domain model, or renames the feature.

## Facts

- **feature**, **feature template**, **domain model** — the vocabulary of this practice
- **concept** — the `a-concept-is-described-by-the-concept-speak-practice` rule, in `rules/`

## Examples

- ❌ "Sales calculation" — breaks R1. The name has no action and no concept.
- ❌ "Refactor the sale service" — breaks R1. It is a task, with no result of value to the customer. The task is done as a part of the feature that needs it.
- ❌ "Calculate the total of a basket", where the domain model has no basket — breaks R2. The feature acts on a thing that nobody defined. Add the concept to the model, or rename the feature.
- ✅ "Calculate the total of a sale"
- ✅ "Assess the fulfillment timeliness of a sale"
- ✅ "Authorize the payment of an order"

## Rationale

The name states what the customer gets. The action is a verb. The result is what the action gives. The concept is in the domain model.

A name in the template says, in one line, what the system does and on what. The customer reads it and knows whether it is of value.

The agent writes the action first. Then it writes the result, the preposition, and the concept. The concept comes from the domain model.

## Related

- the a-feature-list-is-made-from-a-domain-model rule — where the concept comes from
- the a-feature-belongs-to-one-feature-set-of-one-major-feature-set rule — the templates of the sets

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:18:12 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:20:04 PM EDT
