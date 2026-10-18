# Feature-Driven Development — Vocabulary

The feature-driven-development skill's vocabulary: the terms its rules use that `language/vocabulary.md` does not define. Binding — use these terms with these meanings in practices, rules, designs, commits, and prose.

## Terms

**The terms concept, property, and association have the meanings of the concept-speak practice.** The domain model uses them.


- **Feature-Driven Development** — a practice that makes a software system as a list of features, from a model of its domain, in five processes. It differs from a practice that divides the work into tasks, which can give no result of value to the customer.
- **customer** — the stakeholder for whom the software system is made, and who decides what is of value. It differs from a user, who uses the system and does not always decide what it does.
- **architecture** — the set of the significant decisions about the organization of a software system that the design of each feature rests on. It differs from the design of a feature, which states how the concepts do one feature. It differs from the domain model, which shows the concepts and not how the system runs them.
- **domain model** — a model of the domain of a software system, with the properties and the associations of each concept that the domain vocabulary defines, and a note for each decision. It differs from the design of a feature, which shows how the concepts do one feature. It differs from the domain vocabulary, which defines each concept and holds no association.
- **feature** — a function of a software system that gives a result of value to the customer, named for an action on one concept of the domain model. It differs from a task, which is a part of the work and gives no result to the customer.
- **feature template** — the form of the name of a feature: `<action> the <result> <by|for|of|to> a(n) <concept>`. "Calculate the total of a sale" takes the feature template. It differs from the templates of the names of a feature set and a major feature set.
- **feature set** — a classification of features by the one business activity of the domain that they do together. "Making a product sale" is a feature set. It differs from a feature, which has states, and from a major feature set, which classifies feature sets.
- **major feature set** — a classification of feature sets by the one subject area of the domain that they cover together. "Product sales management" is a major feature set. It differs from the domain model, which shows the concepts of the subject area and not its activities.
- **feature list** — the set of the features of a software system, each in a feature set of a major feature set. It differs from a feature record, which records one feature.
- **backlog** — the part of the feature list that no requirements document lists. It differs from the feature list, which holds each feature, in the backlog or not.
- **feature record** — a document that records one feature: its feature set, its major feature set, its plan position, the date of each milestone it reached, and its design. It differs from the feature, which is the function the record is about.
- **plan position** — the number of the place of a feature set in the order of the plan, from 1 for the feature set whose features are designed first. It differs from the date of a milestone, which records when a feature reached it.
- **design of a feature** — the part of a feature record that states how the concepts of the domain model do the feature, with the sequence of calls and each new concept, property, and operation. It differs from the code, which does the feature.
- **operation** — a unit of code that does one action on a concept of the domain model, such as a function of a module or a method of a class. It differs from a feature, which gives a result of value to the customer.
- **milestone** — an event in the work on a feature after it is planned, with a weight. There are six: domain walkthrough, design, design inspection, code, code inspection, and integration. It differs from the state of a feature, which names the last milestone reached.
- **weight** — the percent of the progress of a feature that one milestone gives. The six weights total 100 percent. It differs from progress, which is the sum of the weights a feature reached.
- **state of a feature** — the condition of a feature that its milestones and the requirements documents give: Listed, Planned, Walked Through, Designed, Design Inspected, Coded, Code Inspected, or Integrated. It differs from a milestone, which is an event and not a condition.
- **progress** — the percent of the milestone weights that a feature, a feature set, or a major feature set reached. It differs from the state of a feature, which names a stage and not a percent.
- **inspection** — a review of the design or the code of a feature that ends when the inspector accepts it or rejects it. A design inspection reviews the design, and a code inspection reviews the code. It differs from a unit test, which runs the code.
- **inspector** — the person or the agent who makes an inspection. It differs from the author, who wrote the design or the code that is inspected.
- **build** — the version of the software system on the branch that a local rule of the software system names. It holds each feature that reached the integration milestone. The names of the build a feature list process and the build by feature process are the names that Feature-Driven Development gives them. It differs from the code of one feature, which is not part of the build until its integration.
- **test command** — the command that runs each test of the build. A local rule of the software system names it. It differs from a unit test of a feature, which is one of the tests the command runs.
- **feature size limit** — the threshold that the time of an inspection of one feature is compared against. It differs from the plan position, which orders the feature sets and does not limit a feature.

## Substitutions

Feature-Driven Development was described for object-oriented code. The terms in the **Don't use** column are its older terms. When the impulse is a word in that column, write the **Use** term.

| Use | Don't use | Meaning |
|---|---|---|
| **domain model** | "overall model", "object model" | the model of the concepts of the domain. It is not a model of the code, and it holds no class |
| **concept** | "class", in the domain model | a thing of the domain, as concept-speak defines it. A concept is coded as a module, a type, or a class |
| **property** | "attribute" | a characteristic of a concept, as concept-speak uses it |
| **`<concept>`** | "`<object>`", in the feature template | the concept of the domain model that the feature acts on |
| **operation** | "method", in a design | a unit of code that does one action. "Method" is also an Essence term with a different meaning |
| **customer** | "client" | the stakeholder who decides what is of value. Customer is also the name of an Essence area of concern |
| **integration**, and the `Integrated` state | "promote to build", "promotion", and the `Promoted` state | the milestone at which the code of a feature is merged into the branch of the build |

---

Authored by Nicholas Henry on Fri Oct 16 2026 at 6:45:40 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 6:58:29 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:04:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:06:12 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:14:10 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:16:38 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:18:12 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:29:52 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 8:58:04 PM EDT
Changed by Nicholas Henry on Fri Oct 16 2026 at 9:42:46 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:30:00 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:49:34 AM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:51:15 AM EDT
