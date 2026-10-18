# Build the feature list of the link shortener

## Activity

Build a feature list, of the feature-driven-development practice, from the domain model.

## Work products

- `.essence/local/work-products/features/shorten-the-target-url-for-a-visitor.md` — made in this activity
- `.essence/local/work-products/features/shorten-the-target-url-for-a-user.md` — made in this activity
- `.essence/local/work-products/features/assign-the-plan-to-a-user.md` — made in this activity

## Agent skills

- feature-driven-development — the build a feature list process, the feature template, and the templates of the feature sets
- simplified-technical-english — the prose of this entry
- version-control — the commit

## Decisions

- The feature list has two major feature sets, one for each part of the domain model: Link management, and Plan management.
- Link management holds one feature set, Shortening a target URL, with two features. The feature for a visitor and the feature for a user are two steps, because only the feature for a user has the link limit constraint.
- Plan management holds one feature set, Assigning a plan, with one feature.
- Each feature names a concept of the domain model: visitor, user, and user.
- The agent added no feature that the engineer did not request. A feature that resolves a short URL to its target URL is not in the request, and the agent reports it to the engineer as a candidate.
