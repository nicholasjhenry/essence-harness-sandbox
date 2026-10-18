# Develop the domain model of the resolution and the login

**Activity:** Develop a domain model, of the feature-driven-development practice. Endeavor: `2026-10-18T02-55-34Z-resolve-short-urls-and-log-in-users`.

## Work products

- `.essence/local/work-products/vocabulary.md` — changed. It defines resolution, login token, login link, login session, session token, redemption, and logout.
- `.essence/local/work-products/domain-model.md` — changed. It adds Short URL and Resolution to Part 1, adds Part 3, Login, and adds the hard constraints 4 to 7 and their notes.

## Agent skills

- feature-driven-development
- concept-speak
- simplified-technical-english
- phoenix-auth, from `/Users/nicholas/Workspaces/agents/playbook/src/skills/`, for the flow of a magic link

## Decisions

- The engineer walked through the domain in the request of the session: "Resolve the target URL of a short URL: the redirect. Without it, a short URL leads to a 404." and "A login: today anyone can assign any plan to any email address. This is risk 4 in the architecture."
- The engineer answered four questions. Q1: the parent endeavor is `2026-10-18T02-09-14Z-build-the-first-features-of-the-link-shortener`. Q2: a user logs in by a magic link by email. Q3: a user assigns a plan only to that user. Q4: the login also protects the shortening of a target URL for a user.
- The engineer then stated: "you are fully delegated, no more prompts please". The agent decides each other question of this endeavor, and records it as a decision. The agent takes this statement as the confirmation of the engineer for each approval that the method keeps with the engineer in this endeavor.
- The resolution is a redirect with the status 302 Found, and a short URL with no link gives 404 Not Found.
- The link shortener records no resolution.
- A login token has a lifetime of 15 minutes and one use. The login link opens a page with a button, and the button starts the login session.
- The link shortener keeps only the SHA-256 hash of a login token and of a session token.
