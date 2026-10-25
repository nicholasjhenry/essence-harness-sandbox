# Develop the domain model of the expiration of a link

## Activity

Develop a domain model, of the feature-driven-development practice, for the part of the domain that the feature Expire the link of a user uses.

## Work products

- `.essence/local/work-products/vocabulary.md` — changed: the terms expiration and time of expiration
- `.essence/local/work-products/domain-model.md` — changed: the concept expiration, the property time of expiration of a link, the status of a resolution, hard constraints 9 to 11, and the notes of the walkthrough

## Agent skills

- feature-driven-development
- concept-speak
- simplified-technical-english

## Decisions

The walkthrough is the walkthrough of the engineer by the feature-driven-development practice. It rests on the delegation: "delegated". Each decision takes the recommended option.

1. Only the owner expires a link, by a login session of the owner. A link of a visitor has no owner.
2. The owner sets a time of expiration in UTC, and not a duration.
3. From the time of expiration, the short URL gets `404 Not Found`, and no resolution is recorded. `410 Gone` was not taken, because it says that a link had the short code.
4. A later expiration replaces an earlier one while the time of expiration is not past. No expiration is accepted after it is past. The request names no removal of an expiration.
5. A link whose time of expiration is past still exists. It stays in the list, counts against the link limit, and keeps its short code claimed. The owner can delete it.
6. The concept-speak practice gives the name "time of expiration" to the property, and "expiration" to the event, as "deletion" names an event. No concept is named "expired link", because a name for a property of a concept is a smell of concept-speak.
