# Build the feature list of the resolution and the login

**Activity:** Build a feature list, of the feature-driven-development practice. Endeavor: `2026-10-18T02-55-34Z-resolve-short-urls-and-log-in-users`.

## Work products

- `.essence/local/work-products/features/resolve-the-target-url-of-a-short-url.md` — new
- `.essence/local/work-products/features/send-the-login-link-to-a-user.md` — new
- `.essence/local/work-products/features/redeem-the-login-token-of-a-user.md` — new
- `.essence/local/work-products/features/end-the-login-session-of-a-user.md` — new
- `.essence/local/work-products/features/authorize-the-plan-assignment-of-a-user.md` — new
- `.essence/local/work-products/features/authorize-the-link-shortening-of-a-user.md` — new

## Agent skills

- feature-driven-development

## Decisions

- The resolution is the feature set Resolving a short URL, in the major feature set Link management, with one feature.
- The login is the new major feature set User management. Its feature set Logging in a user has three steps: the login link, the redemption, and the logout.
- The protection of the plan assignment and of the shortening for a user is the feature set Authorizing a user, with one feature for each page. The agent added two new features, and did not amend the two Integrated features "Assign the plan to a user" and "Shorten the target URL for a user". The amendment of an Integrated feature would make its milestone dates false.
- The logout is a feature of the login. A login session with no logout ends only when the browser loses its cookie.
