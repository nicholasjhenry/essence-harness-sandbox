# Install the feature-driven-development practice

## Activity

Install the feature-driven-development extension as a local practice, at the request of the engineer.

## Work products

- `.essence/local/practices/feature-driven-development/` — a copy of `.essence/harness/extensions/feature-driven-development/`
- `.essence/local/rules/the-build-is-the-main-branch.md` — the local rule of the build, which the `the-build-is-stated-in-a-local-rule` rule requires when the practice is installed

## Agent skills

- essentializing — to read the layout of the practice
- rule-speak — to write the local rule of the build
- simplified-technical-english — to write the prose of the rule and of this entry
- version-control — to make the work branch `feat/shorten-links-and-assign-plans` and the commit

## Decisions

- The engineer requested the installation in the session: "install the feature-driven-development practice". R10 of the `a-missing-required-practice-is-reported-to-the-engineer` rule is met.
- The agent copied the extension, and did not link it. The installation step of `.essence/harness/README.md` says to copy each extension.
- The engineer gave no branch and no test command for the build. The agent did not ask, because the engineer instructed the agent to complete the work without prompts. The agent selected `main`, the default branch, and `mix test`, the test command of a Mix project. The engineer can change the rule.
