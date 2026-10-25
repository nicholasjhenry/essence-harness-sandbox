# Record the integration on the work branch of its feature

## Activity

The agent wrote a local rule that records the integration milestone of a feature on the work branch of the feature, before its squash merge, at the request of the engineer: "I think recording the milestone should be done in the same branch as the feature once approved. That way it is included in the same PR/branch and no second review is required". The activity belongs to no endeavor.

## Work products

- `.essence/local/rules/the-integration-milestone-is-recorded-on-the-work-branch-of-its-feature.md` — made

## Agent skills

- rule-speak
- simplified-technical-english
- version-control

## Decisions

- The rule is a local rule. It changes when the feature-driven-development practice records the integration milestone, and not what the milestone states.
- R2 requires that the work branch holds each commit of `main`, so that the squash merge gives `main` the same files on which `mix test` passed.
- R3 makes the record and the squash merge one activity, so that no record states a merge that did not occur.
- The rule applies from the next feature. The integration of the deletion of the link of a user is already on this branch, in pull request 3, because the merge of pull request 1 came before the rule. The agent wrote the rule on this branch, because the work started on it.
