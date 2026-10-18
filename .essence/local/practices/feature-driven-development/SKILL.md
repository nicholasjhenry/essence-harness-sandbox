---
name: feature-driven-development
description: "Feature-Driven Development, from Jeff De Luca and Peter Coad, for making a software system one customer-valued feature at a time. It has five processes: develop a domain model, build a feature list, plan by feature, design by feature, and build by feature. Use when a system or a large change is to be divided into features. Use when writing a feature list, adding a feature, or amending a feature. Use when naming a feature, a feature set, or a major feature set. Use when deciding the order of the feature sets. Use when the architecture of the system is to be selected. Use when the design or the code of a feature starts. Use when recording the milestone a feature reached, or reporting the progress of a feature or a feature set. Trigger on questions like what are the features, what is next, or how far along is this. Trigger on FDD, Feature-Driven Development, architecture, feature list, feature set, feature record, milestone, domain walkthrough, design inspection, code inspection, or integration."
template-name: skill-methodology
template-revision: 2
---

# Feature-Driven Development: A System Made One Feature at a Time

**A software system is made as a list of small features, each of value to the customer.** Feature-Driven Development models the domain first, and divides it into features from the model. It then plans, designs, and codes each feature in turn. Each feature reaches six milestones, and its progress is the sum of the weights of the milestones it reached.

**Adapted from Feature-Driven Development by Jeff De Luca and Peter Coad, and from Stephen R. Palmer and John M. Felsing, A Practical Guide to Feature-Driven Development.** The rules cover the five processes, the feature template, the six milestones and their weights, and the record of each feature. They leave out the roles of chief programmer, class owner, and feature team. The engineer approves the work, and the agent does it.

**The terms of the source are replaced with terms that apply in any programming language.** A domain model of concepts replaces an object model of classes. The customer replaces the client, and the integration milestone replaces promote to build. The vocabulary lists each substitution.

**The rules are written from memory.** None has been checked against the published description of the practice.

**Read every rule in `rules/` and the vocabulary in `vocabulary.md` before applying any of them.** The rules use the vocabulary's terms with its meanings, and each rule names the rules it rests on. A rule applied unread is a rule applied from memory.

---

## When to Use

The frontmatter description drives auto-triggering. This section helps recognize the methodology in conversation.

### Proactive — features to plan, design, and code

- A system or a large change is to be divided into features.
- A feature is to be added to the feature list, or a feature is to be amended.
- The work of a session starts on a feature.
- The engineer asks what is next, or how far along the work is.

### Reactive — feature smells

| Smell | Fix | Rule |
|------------|-----|------|
| A feature list starts from screens or tasks, with no model of the domain | Make the domain model first | a-feature-list-is-made-from-a-domain-model |
| A feature is named as a task, such as "Refactor the sale service" | Name the action, the result, and the concept | a-feature-is-named-by-the-feature-template |
| A feature is in no feature set, or in two | Put it in exactly one | a-feature-belongs-to-one-feature-set-of-one-major-feature-set |
| A feature is more than one step of a business activity, or its inspection needs a break | Divide it into features, or make it a feature set | a-feature-is-one-step-of-a-business-activity-and-is-inspected-within-the-feature-size-limit |
| A feature is designed before the engineer approved an architecture | Propose the architecture first | the-architecture-is-selected-before-the-first-feature-is-designed |
| A feature is designed before its feature set has a plan position | Plan the feature set first | a-feature-set-is-planned-before-its-features-are-designed |
| Code is written before the design is inspected | Inspect the design first | a-feature-reaches-its-milestones-in-order |
| The author of a design inspects it | Ask a different inspector | an-inspection-is-made-by-someone-other-than-the-author |
| A feature is "nearly done", or its record holds a state | Compute the state from the last milestone it reached | the-state-of-a-feature-is-the-last-milestone-it-reached |
| Progress is an estimate | Compute it from the milestone weights | the-progress-of-a-feature-is-the-sum-of-the-weights-of-its-milestones |
| A feature is merged with no branch or test command stated | State the build in a local rule | the-build-is-stated-in-a-local-rule |
| A feature record is moved, or names its endeavor | List it in the requirements document of the endeavor | the-backlog-is-each-feature-that-no-requirements-document-lists |
| An endeavor has no feature | Plan at least one feature into it | a-requirements-document-lists-at-least-one-feature |
| A feature exists only in a conversation | Write its feature record | each-feature-is-recorded-in-a-feature-record |
| A renamed feature keeps its old milestones | Clear its milestone dates | a-feature-is-added-or-amended-in-its-feature-record |

---

## Core Concept

**The domain model gives the feature list its structure, and the feature records give the state of the work.** A major feature set is a subject area of the domain. A feature set is a business activity in it. A feature is a step of that activity. Each feature has one feature record, and the record shows the last milestone the feature reached.

**The terms are defined in `vocabulary.md`:** Feature-Driven Development, customer, architecture, domain model, feature, feature template, feature set, major feature set, feature list, backlog, feature record, plan position, design of a feature, operation, milestone, weight, state of a feature, progress, inspection, inspector, build, test command, and feature size limit. **The terms domain vocabulary, endeavor, and requirements document are defined in `language/vocabulary.md`.**

---

## The Five Processes

The first three processes occur at the start of the work, and again when the domain changes. The last two occur for each feature.

1. **Develop a domain model.**
   1. Ask the engineer to walk through each part of the domain.
   2. Define each concept in the domain vocabulary, in `.essence/local/work-products/vocabulary.md`.
   3. Record the properties and the associations of each concept in `.essence/local/work-products/domain-model.md`.
   4. Write a note for each alternative that the engineer rejects.
2. **Build a feature list.**
   1. Divide the domain into subject areas. Each subject area is a major feature set.
   2. Divide each subject area into business activities. Each business activity is a feature set.
   3. Divide each business activity into steps. Each step is a feature.
   4. Write a feature record for each feature.
3. **Plan by feature.**
   1. Put the feature sets in order of dependency, risk, and value to the customer.
   2. Give each feature set its plan position, from 1 for the first.
   3. Write the plan position in the feature record of each feature of the set.
   4. Ask the engineer to approve the plan.
   5. When the engineer approves it, list the feature record of each feature of the set in the requirements document of the endeavor.
4. **Design by feature.**
   1. Walk through the part of the domain that the feature uses, with the engineer.
   2. Write the design of the feature in its feature record.
   3. Ask an inspector to inspect the design.
5. **Build by feature.**
   1. Write the code and the unit tests of the feature from its design.
   2. Ask an inspector to inspect the code.
   3. Merge the code into the branch of the build.
   4. Run the test command of the build on that branch.

**Record each milestone when the feature reaches it.** Write the date in the feature record. The state of the feature follows from the dates.

**Report the progress from the feature records.** Compute the progress of each feature set and each major feature set. Show the result as a table, with the state of each feature.

---

## Principles

Each rule is a file in `rules/`, named for what it says.

- **a-feature-list-is-made-from-a-domain-model** — the concept of each feature is defined in the domain vocabulary, and is in the domain model.
- **a-feature-is-named-by-the-feature-template** — the name is an action, a result, and a concept: `<action> the <result> <by|for|of|to> a(n) <concept>`.
- **a-feature-belongs-to-one-feature-set-of-one-major-feature-set** — and each set is named by its own template.
- **a-feature-is-one-step-of-a-business-activity-and-is-inspected-within-the-feature-size-limit** — the feature size limit is one period of work of the inspector, with no break.
- **a-feature-set-is-planned-before-its-features-are-designed** — the design of a feature starts only after its feature set has a plan position, and a feature is listed only after the engineer approved its plan.
- **the-architecture-is-selected-before-the-first-feature-is-designed** — the design of a feature starts only after the engineer approved the architecture.
- **a-feature-reaches-its-milestones-in-order** — domain walkthrough, design, design inspection, code, code inspection, and integration.
- **the-build-is-stated-in-a-local-rule** — each software system states the branch and the test command of its build.
- **an-inspection-is-made-by-someone-other-than-the-author** — the engineer, or an agent that did not write the design or the code.
- **the-state-of-a-feature-is-the-last-milestone-it-reached** — the state is computed and not recorded: `Listed` or `Planned` before the first milestone, then the condition that each milestone gives, from `Walked Through` to `Integrated`.
- **each-milestone-carries-a-fixed-weight** — 1, 40, 3, 45, 10, and 1 percent.
- **the-progress-of-a-feature-is-the-sum-of-the-weights-of-its-milestones** — and the progress of a set is the mean of the progress of its features.
- **each-feature-is-recorded-in-a-feature-record** — one file for each feature, in `.essence/local/work-products/features/`.
- **the-backlog-is-each-feature-that-no-requirements-document-lists** — the backlog is computed, and a feature record never moves.
- **a-requirements-document-lists-at-least-one-feature** — an endeavor that applies this practice has at least one feature.
- **a-feature-is-added-or-amended-in-its-feature-record** — a new feature is a new record, and a renamed feature loses its milestone dates.

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 6:58:29 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:04:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:06:12 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:14:10 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:15:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:16:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:18:12 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:58:04 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:42:46 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:30:00 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:49:34 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:51:15 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:53:45 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:12:38 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:23:48 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 12:41:36 PM EDT
