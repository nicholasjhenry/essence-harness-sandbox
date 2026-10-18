# Resolve short URLs and log in users — Requirements

Parent: 2026-10-18T02-09-14Z-build-the-first-features-of-the-link-shortener

The requirements of this endeavor are the features that its records list. The engineer requested them in the session on Sat Oct 17 2026:

1. Resolve the target URL of a short URL: the redirect. Without it, a short URL leads to a 404.
2. A login. Today any person can assign any plan to any email address. This is risk 4 of the architecture.

A user logs in by a login link that the link shortener sends by email. A user assigns a plan only to that user. The shortening of a target URL for a user also needs the login of the user.

## Plan

| Plan position | Feature set | Reason for the position |
|---|---|---|
| 3 | Resolving a short URL | It depends on no other feature set. It gives the most value, because each short URL is of no use without it. |
| 4 | Logging in a user | Authorizing a user reads the login session of the user. It holds the most risk of the endeavor: a new dependency and email delivery. |
| 5 | Authorizing a user | It closes risk 4 of the architecture, and depends on Logging in a user. |

Plan positions 1 and 2 are the feature sets of the parent endeavor.

## Records

- `.essence/local/work-products/features/resolve-the-target-url-of-a-short-url.md`
- `.essence/local/work-products/features/send-the-login-link-to-a-user.md`
- `.essence/local/work-products/features/redeem-the-login-token-of-a-user.md`
- `.essence/local/work-products/features/end-the-login-session-of-a-user.md`
- `.essence/local/work-products/features/authorize-the-plan-assignment-of-a-user.md`
- `.essence/local/work-products/features/authorize-the-link-shortening-of-a-user.md`

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:56:47 PM EDT
