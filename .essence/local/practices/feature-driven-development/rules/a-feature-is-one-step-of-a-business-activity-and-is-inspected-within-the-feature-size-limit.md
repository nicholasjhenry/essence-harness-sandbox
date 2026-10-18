# A feature is one step of a business activity, and is inspected within the feature size limit

## Rules

- **R1.** A feature must be one step of the business activity of its feature set.
  - **Classification:** structural
  - **Enforced:** when a feature is added to the feature list or amended
  - **Violation response:** the agent divides the feature into features, or makes it a feature set.
- **R2.** The time of an inspection of a feature must not be more than the feature size limit.
  - **Classification:** behavioral
  - **Enforced:** when an inspection of a feature is made
  - **Violation response:** the inspector rejects the design or the code. The agent divides the feature into features.
- **R3.** The feature size limit must be one period of work of the inspector, with no break.
  - **Classification:** definitional
  - **Enforced:** where R2 is checked
  - **Violation response:** the agent checks R2 against one period of work of the inspector, and against no other limit.

## Facts

- **feature**, **feature set**, **feature list**, **feature size limit**, **inspection**, **inspector** — the vocabulary of this practice
- **business activity** — the entry for feature set, in the vocabulary of this practice
- **threshold** — the vocabulary of the rule-speak practice, in `practices/rule-speak/`

## Examples

- ❌ "Make the sale of a product", as one feature — breaks R1. It is the business activity of a feature set, and not one step of it.
- ❌ A feature whose code the engineer cannot inspect in one period of work — breaks R2. The engineer then accepts code without a full read.
- ❌ A feature size limit of two weeks — breaks R3. An agent integrates a large feature in hours, so a limit of two weeks never stops a feature.
- ✅ "Calculate the total of a sale", one step of making a product sale, with its code inspected in one period of work.

## Rationale

A small feature shows progress often. A feature that is more than one step is a business activity, and not one step of it.

The source sets a limit of two weeks from the domain walkthrough to the integration milestone. That limit is for a team of people. An agent does the same work in hours. A limit in elapsed time then does not find a large feature. The agent also cannot check an estimate of time.

R1 gives the size that the source intends, without an estimate. The agent checks R1 from the feature list.

R2 checks the size where it costs the most. The inspector reads each line of the design and the code. An inspector that needs a break before the end of an inspection reads the last part with less attention. An agent inspector seldom breaks R2, so R1 holds the size for it.

## Related

- the a-feature-belongs-to-one-feature-set-of-one-major-feature-set rule — the feature set a large feature becomes
- the an-inspection-is-made-by-someone-other-than-the-author rule — the inspector whose period of work R3 names

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:18:12 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:11:24 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:42:46 PM EDT
