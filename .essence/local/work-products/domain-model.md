# Link Shortener — Domain Model

The properties and the associations of each concept of the domain vocabulary, in `.essence/local/work-products/vocabulary.md`. This model does not define a concept again. It has three parts of the domain.

## Part 1. Links

### Link

- **Properties:**
  - short code — exactly one. No two links have the same short code.
  - target URL — exactly one.
  - time of shortening — exactly one. The time at which the link shortener made the link.
- **Associations:**
  - a link has zero or one owner, who is a user.
  - a link is written as exactly one short URL.

### Short URL

- **Properties:**
  - path — `/` and the short code of the link.
- **Associations:**
  - a short URL writes exactly one link.
  - a short URL has zero or more resolutions.

### Resolution

- **Properties:**
  - status — `302 Found` with the target URL, if a link has the short code. `404 Not Found`, if no link has it.
- **Associations:**
  - a resolution resolves exactly one short URL.
  - the link shortener records no resolution.

### Short code

- **Properties:**
  - characters — seven letters or digits, from `A`–`Z`, `a`–`z`, and `0`–`9`.
- **Associations:**
  - a short code identifies exactly one link.
  - a short code is made by the link shortener, or is chosen by the person who shortens the target URL. The link does not record which.

### Target URL

- **Properties:**
  - scheme — `http` or `https`.
  - host — exactly one, not empty.
- **Associations:**
  - a target URL is referred to by zero or more links. Two links can refer to the same target URL.

### Visitor

- **Properties:** none that the link shortener records.
- **Associations:**
  - a visitor shortens zero or more links. The links have no owner.

## Part 2. Users and plans

### User

- **Properties:**
  - email address — exactly one. No two users have the same email address.
- **Associations:**
  - a user owns zero or more links.
  - a user is on exactly one plan at a time: the plan of the latest plan assignment of the user, or the default plan.
  - a user has zero or more plan assignments.

### Plan

- **Properties:**
  - name — exactly one.
  - link limit — zero or one number. A plan with no link limit permits any number of links.
- **Instances:**

  | Plan | Link limit |
  |---|---|
  | Free | 10 |
  | Pro | none |

- **Associations:**
  - a plan applies to zero or more users.

### Plan assignment

- **Properties:**
  - time of assignment — exactly one.
- **Associations:**
  - a plan assignment puts exactly one user on exactly one plan.

## Part 3. Login

### Login token

- **Properties:**
  - secret — 32 random bytes. The link shortener keeps only the SHA-256 hash of the secret.
  - time of sending — exactly one.
  - lifetime — 15 minutes from the time of sending.
- **Associations:**
  - a login token is for exactly one user.
  - a login token has zero or one redemption.
  - a login token is carried by exactly one login link.

### Login link

- **Properties:**
  - path — `/log-in/` and the login token.
- **Associations:**
  - a login link is sent to the email address of the user of its login token.

### Redemption

- **Properties:**
  - time of redemption — exactly one.
- **Associations:**
  - a redemption accepts exactly one login token.
  - a redemption starts exactly one login session.

### Login session

- **Properties:**
  - session token — 32 random bytes. The browser holds the session token, and the link shortener keeps only its SHA-256 hash.
- **Associations:**
  - a login session is of exactly one user.
  - a login session is started by exactly one redemption.
  - a login session is ended by zero or one logout.

### Logout

- **Properties:**
  - time of logout — exactly one.
- **Associations:**
  - a logout ends exactly one login session.

### User, in Part 3

- **Associations:**
  - a user has zero or more login tokens.
  - a user has zero or more login sessions.

## Hard constraints

1. The short code of a new link must not be the short code of a link that exists.
2. The number of links of an owner must not be more than the link limit of the plan of the owner.
3. A plan assignment must not put a user on the plan that the user is on.
4. A login token must not have more than one redemption.
5. A redemption of a login token must not occur after the lifetime of the login token.
6. A plan assignment must not put a user on a plan, other than by a login session of that user.
7. A link with an owner must not be made, other than by a login session of the owner.

## Notes

- **Source of the walkthrough.** The engineer walked through the domain in the request of the session on Sat Oct 17 2026: "shorten a link", "shorten a link for a user", and "assign a plan to the user". The engineer then approved the plans Free, with a link limit of 10, and Pro, with no link limit, and the identification of a user by email address.
- **A user is known by email address, with no registration.** A user exists for the link shortener from the first link or the first plan assignment for the email address. Registration and login are not in the request. The engineer approved this decision.
- **A link of a visitor has no link limit.** The request names a plan only for a user. A limit for visitors is not in the request.
- **The default plan is Free.** A user with no plan assignment is on a plan, so that constraint 2 applies to each user.
- **A change to a plan with a smaller link limit is permitted.** A user with 12 links can go from Pro to Free. Constraint 2 then stops each new link of the user, and keeps the 12 links that exist.
- **The plans are fixed.** The request names no feature that adds or changes a plan. The two plans are a part of the link shortener, and not of its data.
- **The short code is made by the link shortener, or chosen by the person.** In the first endeavor, the request named no chosen short code. The engineer requested the choice of the short code on Sat Oct 24 2026, and delegated the decisions of the walkthrough: "I'm delegating this endeavor complete to you". Seven characters from 62 give about 3.5 × 10¹² short codes.
- **A chosen short code has the form of each short code: seven letters or digits.** The resolution and the router rest on this form. No path of a page has it, so a chosen short code never hides a page.
- **A visitor and a user can each choose the short code.** The feature is a step of Shortening a target URL, for each person who shortens.
- **A chosen short code that a link has makes no link.** The person chooses a different short code. The link shortener does not replace it with a short code that it makes, because the person asked for that short code. Hard constraint 1 applies to a chosen short code as to each short code.
- **A short code is chosen with upper case and lower case as two different characters.** `Summer1` and `summer1` are two short codes, as for each short code that the link shortener makes.
- **Alternative that the agent did not take: a chosen short code of 3 to 32 characters, with dashes.** It gives the person more freedom. A chosen short code such as `plans` or `log-in` would then be the path of a page, and the router would need a list of reserved paths.
- **Alternative that the agent did not take: one link for each target URL.** Two shortenings of the same target URL give two links. One link for each target URL would make the link of one user the link of a different user, with a different owner.
- **Source of the walkthrough of Parts 1 and 3, on Sat Oct 17 2026.** The engineer requested the resolution: "Resolve the target URL of a short URL: the redirect. Without it, a short URL leads to a 404." The engineer requested a login, for risk 4 of the architecture: "today anyone can assign any plan to any email address." The engineer then selected a login by magic link, a plan assignment by a user to that user only, and a login for the shortening for a user. The engineer delegated the other decisions: "you are fully delegated, no more prompts please".
- **The resolution is a redirect with the status 302 Found.** A browser keeps a 301 redirect in its cache, and then does not ask the link shortener again.
- **The link shortener records no resolution.** The request names no count of the uses of a link. A record of each resolution would add a write to each read.
- **A login needs no registration.** A user exists from the first link, the first plan assignment, or the first login token for the email address, as in Part 2.
- **The login link starts no login session by itself.** It opens a page with one button, and the button starts the login session. A mail scanner that opens each link in an email then does not log in.
- **The lifetime of a login token is 15 minutes.** It is the lifetime that `phx.gen.auth` gives a magic link.
- **A user assigns a plan only to that user.** The engineer selected this. No administrator exists. With no payment, a user can select the Pro plan.
- **Alternative that the engineer did not take: an email address and a password.** It does not prove that the person owns the email address.
- **Source of the walkthrough of the listing of the links of a user, on Sat Oct 24 2026.** The engineer requested "implement "List the links of a user" only", and delegated the decisions of the walkthrough: "delegating this to you fully". The listing uses the concepts link, owner, short URL, target URL, and user of Parts 1 and 2. It adds no concept, no property, and no association.
- **A user sees only the links that the user owns.** The owner is the user of the login session, and never a value of a form or a URL. A link of a visitor has no owner, so no user sees it in a list.
- **The list shows the short URL, the target URL, and the time of shortening of each link, the newest link first.** These are the properties of a link that the domain model records.
- **The list holds each link of the user, with no pages.** A user on the Free plan has at most 10 links. A user on the Pro plan can have more, and one list on one computer is far below the limit of SQLite.
- **Alternative that the agent did not take: the list on the page that shortens a target URL.** That page belongs to the feature Shorten the target URL for a user. A page of its own keeps each feature in its own slice.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:08:34 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:55:34 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 7:57:58 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:26:28 PM EDT
