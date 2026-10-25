# Integrate the expiration of the link of a user

## Activity

The integration of the feature Expire the link of a user, in Build by Feature. The engineer requested the merge of pull request 9: "comments have been address, let's merge".

## Work products

- `.essence/local/work-products/features/expire-the-link-of-a-user.md` — the date of the integration milestone.

## Agent skills

- version-control
- feature-driven-development

## Decisions

- The integration milestone is recorded on the work branch `feat/expire-the-link-of-a-user`, before its squash merge, by the `the-integration-milestone-is-recorded-on-the-work-branch-of-its-feature` rule. The work branch holds each commit of `main`, and `mix test` passed on it at `5dcde6c`, with 228 tests.
- The findings of the review of pull request 9 are answered at `5dcde6c`. F1: the term time of setting is in the domain vocabulary. F3: the action of a link with a later time of expiration is `Change expiration`. F2, the time of expiration in UTC, stays as the domain model decided.
- The source record of Software System Architecture Selected names `.essence/local/work-products/architecture.md` as its evidence. This activity does not change it, so no checkpoint is stale.
- The work branch is squash-merged into `main` with the header `feat(links): expire the link of a user (#9)`.
