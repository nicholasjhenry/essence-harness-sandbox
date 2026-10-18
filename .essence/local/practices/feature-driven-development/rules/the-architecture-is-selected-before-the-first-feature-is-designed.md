# The architecture is selected before the first feature is designed

## Rules

- **R1.** The domain walkthrough of a feature may start only if the engineer approved the architecture of the software system.
  - **Classification:** behavioral
  - **Enforced:** when the domain walkthrough of a feature starts
  - **Violation response:** the agent does not start the walkthrough. The agent proposes the architecture to the engineer, and asks the engineer to approve it.
- **R2.** The proposal of an architecture must state each of the following:
  - the criteria by which the architecture is selected
  - the platforms on which the software system runs
  - the programming languages and the technologies
  - the boundary of the software system
  - the significant decisions about the organization of the software system
  - the decisions to buy, build, or reuse
  - the key technical risks
  - **Classification:** structural
  - **Enforced:** when an architecture is proposed to the engineer
  - **Violation response:** the agent adds each missing item, and asks the engineer to approve the proposal again.
- **R3.** The architecture must be recorded in `.essence/local/work-products/architecture.md` when the engineer approves it.
  - **Classification:** structural
  - **Enforced:** when the engineer approves the architecture
  - **Violation response:** the agent writes the approved architecture in `.essence/local/work-products/architecture.md`.

## Facts

- **architecture**, **feature**, **domain walkthrough** — the vocabulary of this practice
- **software system**, **engineer** — `language/vocabulary.md`

## Examples

- ❌ The agent starts the walkthrough of the first feature of a new system, and the engineer approved no architecture — breaks R1. The design of the feature then selects the language, the storage, and the boundary of the system by chance.
- ❌ The agent proposes "Elixir and Phoenix" as the architecture — breaks R2. The proposal states no platform, no boundary, and no risk, and the engineer approves less than the design rests on.
- ❌ The engineer approves the architecture in a conversation, and the agent records it nowhere — breaks R3. The next session then cannot find the decisions.
- ✅ The agent proposes each item of R2. The engineer approves the proposal, and the agent writes it in `.essence/local/work-products/architecture.md`. Then the agent starts the walkthrough of the first feature.

## Rationale

The design of each feature rests on the architecture. A design made before the architecture is selected makes the decisions of the architecture one feature at a time, and no one approves them.

The architecture is selected once, before the first design. A later change to the architecture is proposed to the engineer, and recorded in the same file.

The engineer approves the architecture, because the engineer accepts its risks.

## Related

- the a-feature-set-is-planned-before-its-features-are-designed rule — the other condition for the start of the walkthrough
- the a-feature-reaches-its-milestones-in-order rule — the domain walkthrough this rule comes before

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 11:49:34 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:53:45 AM EDT
