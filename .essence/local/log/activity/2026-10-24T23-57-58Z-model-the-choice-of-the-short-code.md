# Model the choice of the short code

## Activity

Develop a domain model, of the feature-driven-development practice, for Part 1 of the domain model, Links.

## Work products

- `.essence/local/work-products/vocabulary.md` — changed. A short code is made by the link shortener, or chosen by the person who shortens the target URL.
- `.essence/local/work-products/domain-model.md` — changed. The short code has a new association, and the notes record the decisions of the walkthrough.

## Agent skills

- feature-driven-development
- concept-speak
- simplified-technical-english

## Decisions

- The walkthrough of Part 1 rests on the request of the engineer on Sat Oct 24 2026: "Let start a new endeavor for the feature choose-the-short-code-of-a-link". The engineer delegated the decisions of the walkthrough: "I'm delegating this endeavor complete to you". The agent made each decision below, and asked no question.
- A chosen short code has the form of each short code: seven letters or digits. The resolution and the router rest on this form, and no path of a page has it.
- A visitor and a user can each choose the short code.
- A chosen short code that a link has makes no link. The link shortener does not replace it with a short code that it makes.
- A chosen short code keeps upper case and lower case as two different characters.
- The agent did not take the alternative of a chosen short code of 3 to 32 characters with dashes. It would need a list of reserved paths in the router.
- The agent added no term to the domain vocabulary. The definition of short code changed, and the link does not record whether its short code was made or chosen.
