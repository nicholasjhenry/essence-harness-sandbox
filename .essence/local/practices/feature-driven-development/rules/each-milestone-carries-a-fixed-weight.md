# Each milestone carries a fixed weight

## Rules

- **R1.** The weight of the domain walkthrough milestone must be 1 percent.
  - **Classification:** definitional
  - **Enforced:** when the progress of a feature is computed
  - **Violation response:** the agent computes the progress again with this weight.
- **R2.** The weight of the design milestone must be 40 percent.
  - **Classification:** definitional
  - **Enforced:** when the progress of a feature is computed
  - **Violation response:** the agent computes the progress again with this weight.
- **R3.** The weight of the design inspection milestone must be 3 percent.
  - **Classification:** definitional
  - **Enforced:** when the progress of a feature is computed
  - **Violation response:** the agent computes the progress again with this weight.
- **R4.** The weight of the code milestone must be 45 percent.
  - **Classification:** definitional
  - **Enforced:** when the progress of a feature is computed
  - **Violation response:** the agent computes the progress again with this weight.
- **R5.** The weight of the code inspection milestone must be 10 percent.
  - **Classification:** definitional
  - **Enforced:** when the progress of a feature is computed
  - **Violation response:** the agent computes the progress again with this weight.
- **R6.** The weight of the integration milestone must be 1 percent.
  - **Classification:** definitional
  - **Enforced:** when the progress of a feature is computed
  - **Violation response:** the agent computes the progress again with this weight.

## Facts

- **weight**, **milestone**, **progress** — the vocabulary of this practice
- **domain walkthrough**, **design**, **design inspection**, **code**, **code inspection**, **integration** — the milestones of the `a-feature-reaches-its-milestones-in-order` rule

## Examples

- ❌ The design milestone of one feature is given 30 percent, because its design was short — breaks R2. The progress of two features then has two meanings.
- ✅ Each feature uses the same six weights.

## Rationale

Fixed weights make the progress of a feature a computed value, not an estimate.

The weights total 100 percent. They show where the effort of a feature goes. The design and the code take most of it.

## Related

- the the-progress-of-a-feature-is-the-sum-of-the-weights-of-its-milestones rule — the computation that uses the weights

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
