# Feature-Driven Development — Essence

## Objective

A software system is made as a list of small features of value to the customer, and the progress of each feature is visible at each milestone.

## Alphas

- **Requirements** — the feature list states what the software system must do, as features of value to the customer.
- **Feature** — a sub-alpha of Requirements.
  1. **Listed**
     - The name of the feature takes the feature template.
     - The feature belongs to exactly one feature set of exactly one major feature set.
     - The feature record of the feature exists.
  2. **Planned**
     - The feature set of the feature has a plan position.
     - The feature record holds the plan position.
     - A requirements document lists the feature record of the feature.
     - The engineer approved the plan.
  3. **Walked Through**
     - The engineer walked through the part of the domain that the feature uses.
  4. **Designed**
     - The design of the feature is in its feature record.
  5. **Design Inspected**
     - An inspector who is not the author of the design accepted it.
  6. **Coded**
     - The code and the unit tests of the feature are written.
     - Each unit test of the feature passes.
  7. **Code Inspected**
     - An inspector who is not the author of the code accepted it.
  8. **Integrated**
     - The code of the feature is merged into the branch of the build.
     - The test command of the build passes on the branch of the build.
  - **Contributes to:**
    - Requirements Coherent, when each feature that the requirements document of the endeavor lists is Planned.
    - Requirements Fulfilled, when each feature that the requirements document of the endeavor lists is Integrated.
- **Software System** — the engineer approves the architecture, and each feature that reaches the integration milestone adds a function to the build.
- **Work** — the plan puts the feature sets in order, and the progress of each feature set shows how far the work is.

## Work products

- **domain vocabulary** — the work product that `language/vocabulary.md` defines, in `.essence/local/work-products/vocabulary.md`. It defines each concept of the domain model.
  - **Describes:** Requirements.
- **architecture** — a document that records the architecture of a software system, in `.essence/local/work-products/architecture.md`.
  - **Describes:** Software System.
  - **Evidences:** Software System Architecture Selected.
- **domain model** — a model of the domain of a software system, with the properties and the associations of each concept that the domain vocabulary defines, and a note for each decision, in `.essence/local/work-products/domain-model.md`.
  - **Describes:** Requirements.
  1. **Domain Covered**
     - Each part of the domain has a walkthrough with the engineer.
     - Each concept of each part is defined in the domain vocabulary.
     - Each concept of each part is in the model, with its properties and its associations.
- **feature list** — the set of the features of a software system, each in a feature set of a major feature set.
  - **Describes:** Requirements.
- **requirements document** — a work product of an endeavor that states the requirements of the endeavor, and lists the feature records that the endeavor tracks, at `requirements.md` in the directory of the endeavor.
  - **Describes:** Requirements.
  - **Evidences:** Feature Planned, Requirements Coherent, Requirements Fulfilled.
- **feature record** — a document that records one feature: its feature set, its major feature set, its plan position, the date of each milestone it reached, and its design, in `.essence/local/work-products/features/`.
  - **Describes:** Feature.
  - **Evidences:** Feature Listed, Feature Planned, Feature Walked Through, Feature Designed, Feature Design Inspected, Feature Coded, Feature Code Inspected, Feature Integrated.
- **source code** — the code and the unit tests that do a feature, merged into the build.
  - **Describes:** Software System.
  - **Evidences:** Feature Coded, Feature Integrated.

## Activities

- **Develop a domain model** — an activity that defines the concepts of a domain in the domain vocabulary, and records their properties and their associations in the domain model, from a walkthrough of each part of the domain.
  - **Activity space:** Understand the Requirements.
  - **Produces:** domain vocabulary, domain model.
  - **Updates:** domain vocabulary, domain model.
  - **Completion criteria:** domain model Domain Covered.
  - **Competencies:** Analysis.
- **Build a feature list** — an activity that divides a domain into major feature sets, feature sets, and features, and writes a feature record for each feature.
  - **Activity space:** Understand the Requirements.
  - **Produces:** feature list, feature record.
  - **Updates:** feature list.
  - **Completion criteria:** each Feature Listed.
  - **Competencies:** Analysis.
- **Plan by feature** — an activity that puts the feature sets in order, gives each one its plan position, and lists their features in the requirements document of the endeavor when the engineer approves the plan.
  - **Activity space:** Coordinate Activity.
  - **Updates:** feature record, requirements document.
  - **Completion criteria:** each Feature that the requirements document lists is Planned.
  - **Competencies:** Management.
- **Select the architecture** — an activity that proposes the architecture of a software system to the engineer, and records it when the engineer approves it.
  - **Activity space:** Shape the System.
  - **Produces:** architecture.
  - **Completion criteria:** Software System Architecture Selected.
  - **Competencies:** Development.
- **Design by feature** — an activity that takes a feature through the domain walkthrough, design, and design inspection milestones.
  - **Activity space:** Shape the System.
  - **Entry criteria:** Feature Planned, Software System Architecture Selected.
  - **Updates:** feature record.
  - **Completion criteria:** Feature Design Inspected.
  - **Competencies:** Analysis, Development, Testing.
- **Build by feature** — an activity that takes a feature through the code, code inspection, and integration milestones.
  - **Activity space:** Implement the System.
  - **Entry criteria:** Feature Design Inspected.
  - **Produces:** source code.
  - **Updates:** feature record.
  - **Completion criteria:** Feature Integrated.
  - **Competencies:** Development, Testing.
- **Report the progress by feature** — an activity that computes the progress of each feature set and each major feature set from the feature records.
  - **Activity space:** Track Progress.
  - **Completion criteria:** Work Under Control.
  - **Competencies:** Management.

## Competencies

- **Analysis** — to model the domain with the engineer, to divide it into features of value to the customer, and to walk through the part of the domain that a feature uses.
- **Development** — to propose the architecture, and to design and code each feature from the domain model.
- **Testing** — to write the unit tests of each feature, and to inspect a design or code.
- **Management** — to put the feature sets in order, and to report the progress of each one.

## Patterns

- **independent inspection** — a role in which a person or an agent accepts or rejects the design or the code of a feature that a different author wrote.
  - **Arranges:** Design by feature, Build by feature, Feature Design Inspected, Feature Code Inspected, Testing.

## Required practices

- **Inspect the design of a feature** — a practice with an activity in Shape the System that gives the acceptance or the rejection of the design of a feature, by an inspector who is not its author.
  - **Needed by:** Design by feature, for the design inspection milestone.
- **Code a feature** — a practice with an activity in Implement the System that gives the code and the unit tests of a feature, from its design, with each unit test passing.
  - **Needed by:** Build by feature, for the code milestone.
- **Inspect the code of a feature** — a practice with an activity in Test the System that gives the acceptance or the rejection of the code of a feature, by an inspector who is not its author.
  - **Needed by:** Build by feature, for the code inspection milestone.

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 6:58:29 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:04:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:14:10 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:15:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:16:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:18:12 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:25:36 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:58:04 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:10:41 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:30:00 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:49:34 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:51:15 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:53:45 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:08:16 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:12:38 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:23:48 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:41:36 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 9:09:17 PM EDT
