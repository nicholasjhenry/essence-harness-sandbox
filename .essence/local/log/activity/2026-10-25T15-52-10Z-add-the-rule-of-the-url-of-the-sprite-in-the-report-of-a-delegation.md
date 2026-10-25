# Add the rule of the URL of the sprite in the report of a delegation

## Activity

The definition of a local rule, at the request of the engineer: "let's create a rule that the URL should be given once the delegated endeavor is completed".

## Work products

- `.essence/local/rules/the-report-of-complete-delegated-work-gives-the-url-of-its-sprite.md` — made

## Agent skills

- rule-speak
- simplified-technical-english
- version-control

## Decisions

- The URL is the URL of the sprite of the endeavor. The engineer asked "what's the URL?" after the report of the pull request, which held only the URL of the pull request.
- The rule is a local rule in `.essence/local/rules/`, because the sprite and its service are of this repository, in `AGENTS.md`.
- The rule applies only to an endeavor whose work is done in a sprite. An endeavor in the local repository has no URL that the engineer can open apart from the computer of the engineer.
- R2 takes the URL from the Fly MCP server or the `sprite` CLI, because the URL holds a suffix that the name of the sprite does not give.
