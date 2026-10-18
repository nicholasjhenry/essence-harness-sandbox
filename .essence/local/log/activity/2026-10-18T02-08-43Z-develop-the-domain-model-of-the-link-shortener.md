# Develop the domain model of the link shortener

## Activity

Develop a domain model, of the feature-driven-development practice, for the two parts of the domain: links, and users and plans.

## Work products

- `.essence/local/work-products/vocabulary.md` — the domain vocabulary, made in this activity
- `.essence/local/work-products/domain-model.md` — the domain model, made in this activity

## Agent skills

- feature-driven-development — the develop a domain model process
- concept-speak — the genus and the differentia of each term, and the twelve checks
- simplified-technical-english — the prose of both documents and of this entry
- version-control — the commit

## Decisions

- Initialization found no domain vocabulary. The agent reported it to the engineer in the first response of the session, and did not make an empty file. This activity makes the vocabulary with the terms of the domain.
- The walkthrough of each part of the domain is the request of the engineer in this session. The engineer instructed the agent to complete the work without prompts, so the agent asked no further questions. The domain model names the source of the walkthrough in its notes.
- The engineer approved D3 of the first response of the agent: the plans Free, with a link limit of 10, and Pro, with no link limit, and a user known by email address with no login. The engineer gave the approval with the instruction "complete the endeavor".
- The agent named three hard constraints in the domain model: a unique short code, the link limit of the plan of an owner, and no plan assignment to the plan that the user is on.
- The agent made the default plan Free, so that each user is on a plan.
- The agent did not name a visitor link as "anonymous link". The concept-speak practice names a concept for what it is. A link of a visitor is a link with no owner.
