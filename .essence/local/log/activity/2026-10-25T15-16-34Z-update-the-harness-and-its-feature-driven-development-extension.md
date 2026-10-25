# Update the harness and its feature-driven-development extension

## Activity

Update the harness submodule from `3a0d0c7` to `2997389`, and install the feature-driven-development extension again from it. The extension now holds the rule that records the integration milestone on the work branch of its feature, so the local rule is removed. The engineer requested the update. The activity belongs to no endeavor.

## Work products

- `.vendor/essence-harness` — changed, to `2997389`.
- `.essence/local/practices/feature-driven-development/` — changed. It is a new copy of the extension at `2997389`, with the rule `the-integration-milestone-is-recorded-on-the-work-branch-of-its-feature` and the changed `the-build-is-stated-in-a-local-rule`.
- `.essence/local/rules/the-integration-milestone-is-recorded-on-the-work-branch-of-its-feature.md` — removed.

## Agent skills

- version-control
- simplified-technical-english

## Decisions

- The agent removed the old copy of the extension before `install-extension.sh` ran, because the script does not overwrite an installed extension. The old copy held no local change: it was the same as the extension at `3a0d0c7`.
- The local rule is removed, because the rule of the extension states the same rules. The `the-build-is-the-main-branch` local rule still gives the branch and the test command of the build.
