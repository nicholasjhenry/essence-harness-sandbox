# Link Shortener — Domain Model

The properties and the associations of each concept of the domain vocabulary, in `.essence/local/work-products/vocabulary.md`. This model does not define a concept again. It has three parts of the domain.

## Part 1. Links

### Link

- **Properties:**
  - short code — exactly one. No two links have the same short code.
  - target URL — exactly one.
  - time of shortening — exactly one. The time at which the link shortener made the link.
  - time of expiration — zero or one. The time of expiration of the latest expiration of the link.
- **Associations:**
  - a link has zero or one owner, who is a user.
  - a link is written as exactly one short URL.
  - a link has zero or one deletion. A link that has a deletion no longer exists.
  - a link has zero or more resolutions, through its short URL.
  - a link has zero or more expirations. The latest one gives the time of expiration of the link.

### Short URL

- **Properties:**
  - path — `/` and the short code of the link.
- **Associations:**
  - a short URL writes exactly one link.
  - a short URL has zero or more resolutions.

### Resolution

- **Properties:**
  - status — `302 Found` with the target URL, if a link has the short code and the time of expiration of the link is not past. `404 Not Found`, if no link has the short code, or the time of expiration of its link is past.
  - time of resolution — exactly one.
  - target URL — exactly one, if the status is `302 Found`. The target URL to which the link shortener sent the person.
- **Associations:**
  - a resolution resolves exactly one short URL.
  - the link shortener records each resolution with the status `302 Found`. It records no resolution with the status `404 Not Found`.

### Short code

- **Properties:**
  - characters — seven letters or digits, from `A`–`Z`, `a`–`z`, and `0`–`9`.
  - availability — `available`, if no link has the short code and no deleted link had it. `taken`, otherwise. Hard constraint 1 gives it.
- **Associations:**
  - a short code identifies exactly one link.
  - a short code is made by the link shortener, or is chosen by the person who shortens the target URL. The link does not record which.

### Target URL

- **Properties:**
  - scheme — `http` or `https`.
  - host — exactly one, not empty.
- **Associations:**
  - a target URL is referred to by zero or more links. Two links can refer to the same target URL.

### Deletion

- **Properties:**
  - time of deletion — exactly one.
- **Associations:**
  - a deletion removes exactly one link, which has an owner.
  - a deletion is requested by the owner of the link.

### Expiration

- **Properties:**
  - time of expiration — exactly one. It is after the time of setting.
  - time of setting — exactly one. The time at which the owner set the expiration.
- **Associations:**
  - an expiration sets the time of expiration of exactly one link, which has an owner.
  - an expiration is requested by the owner of the link.

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
  - a user requests zero or more deletions, each of a link that the user owns.
  - a user requests zero or more expirations, each of a link that the user owns.
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

1. The short code of a new link must not be the short code of a link that exists, or of a link that has a deletion.
2. The number of links of an owner must not be more than the link limit of the plan of the owner.
3. A plan assignment must not put a user on the plan that the user is on.
4. A login token must not have more than one redemption.
5. A redemption of a login token must not occur after the lifetime of the login token.
6. A plan assignment must not put a user on a plan, other than by a login session of that user.
7. A link with an owner must not be made, other than by a login session of the owner.
8. A link must not be deleted, other than by a login session of its owner.
9. A link must not get an expiration, other than by a login session of its owner.
10. The time of expiration of an expiration must be after the time of setting of the expiration.
11. A link whose time of expiration is past must not get an expiration.

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
- **The link shortener records no resolution.** The request names no count of the uses of a link. A record of each resolution would add a write to each read. The count of the resolutions of a link replaced this decision on Sun Oct 25 2026. The notes of that walkthrough follow the notes of the deletion.
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
- **Source of the walkthrough of the deletion of the link of a user, on Sat Oct 24 2026.** The engineer requested "new endeavor: delete-the-link-of-a-user", and delegated the decisions of the walkthrough: "delegated to you". The deletion adds the concept deletion, and uses the concepts link, owner, short code, short URL, resolution, and user of Parts 1 and 2.
- **Only the owner deletes a link.** The owner is the user of the login session, and never a value of a form or a URL. A link of a visitor has no owner, so no person can delete it.
- **A deletion cannot be undone.** The request names no restore. The user shortens the target URL again to get a new link.
- **The short code of a deleted link is given to no new link.** A person who has the short URL from before the deletion then gets `404 Not Found`, and never the target URL of a different link. Hard constraint 1 holds this.
- **A deleted link does not count against the link limit.** Hard constraint 2 counts the links of the owner that exist. A user on the Free plan with 10 links deletes one, and can then shorten a target URL again.
- **A request to delete a link that the user does not own gets the same answer as a request for a short code of no link.** The answer then does not say whether a link of a different user has the short code.
- **The user deletes a link from the list of the links of the user, and confirms the deletion first.** The list is the one place that shows each link of the user.
- **Alternative that the agent did not take: a short code of a deleted link that a new link can take.** It gives more short codes. A short URL that a person saved would then send that person to the target URL of a different person.
- **Alternative that the agent did not take: a deletion that hides the link and keeps its resolution.** The user who deletes a link expects that its short URL stops.
- **Source of the walkthrough of the count of the resolutions of a link, on Sun Oct 25 2026.** The engineer requested "implement: Count the resolutions of a link", and delegated the decisions of the walkthrough: "completely delegated". The count uses the concepts resolution, link, short URL, owner, and user of Parts 1 and 2. It adds the properties time of resolution and target URL to a resolution, and the association of a link with its resolutions.
- **The link shortener records each resolution that finds a link.** Each resolution adds one write to the read of the link. Risk 1 of the architecture covers the rate of writes on one computer.
- **A resolution with the status `404 Not Found` is not recorded.** Any person can request any path. A record of each such request would let a person add events to the event store with no link.
- **The resolution of a link of a visitor is recorded, as the resolution of a link of a user is.** A resolution is the same event for each link. No page shows the count of a link of a visitor, because no list holds a link of a visitor.
- **Each resolution counts, with no difference between two persons.** A resolution by the owner, by a second person, or by a program counts as one resolution. The link shortener does not know the person who resolves a short URL.
- **The list of the links of a user shows the number of resolutions of each link.** The list is the one place that shows each link of the user.
- **A resolution records the target URL to which it sent the person.** The feature Change the target URL of a link is in the backlog. A record of the target URL then still says where each resolution went.
- **A deletion keeps the resolutions of the link.** A resolution is a fact of the past. The list does not show a deleted link, so it shows no count of a deleted link.
- **The page of the links of a user reads each resolution of the links of the user.** The read grows with each resolution, and holds the resolutions of deleted links too. One user on one computer is far below the limit of SQLite, as for the list itself.
- **Alternative that the agent did not take: a count of the resolutions in a table of its own.** Decision 9 of the architecture gives the software system no read model table. The page reads the resolutions of the links of one user through a projection.
- **Source of the walkthrough of the expiration of the link of a user, on Sun Oct 25 2026.** The engineer requested "new endeavor: Expire the link of a user only", and delegated the decisions of the walkthrough: "delegated". The expiration adds the concept expiration and the property time of expiration of a link. It uses the concepts link, owner, short URL, resolution, deletion, and user of Parts 1 and 2.
- **Only the owner expires a link.** The owner is the user of the login session, and never a value of a form or a URL. A link of a visitor has no owner, so no person can expire it.
- **The owner sets a time of expiration, and not a duration.** The model records the time in each case. A time states the result directly. The owner writes the time in UTC, because the list of the links of a user shows each time in UTC.
- **From the time of expiration, the short URL gets `404 Not Found`.** A request for a short code of no link gets the same answer. The link shortener records no resolution with the status `404 Not Found`, so it records no resolution of a link whose time of expiration is past.
- **A later expiration replaces an earlier one, while the time of expiration is not past.** The owner can move the time earlier or later.
- **The time of expiration of a link does not change after it is past.** Hard constraint 11 holds this. The owner can delete the link.
- **A link whose time of expiration is past still exists.** It stays in the list of the links of the user, with its time of expiration and its number of resolutions. It counts against the link limit, because hard constraint 2 counts the links of the owner that exist. The owner deletes the link to shorten a target URL again on a full plan.
- **The short code of a link whose time of expiration is past is given to no new link.** Hard constraint 1 holds this, because the link exists.
- **Alternative that the agent did not take: an expiration at once, with no time.** A deletion already stops a short URL at once.
- **Alternative that the agent did not take: the removal of an expiration.** The request names no removal. The owner moves the time of expiration later in its place.
- **Alternative that the agent did not take: `410 Gone` for a link whose time of expiration is past.** The answer would say that a link had the short code. A deleted link gets `404 Not Found` for the same reason.
- **Alternative that the agent did not take: a link whose time of expiration is past does not count against the link limit.** The link still exists, and its owner still sees it. The count of the links of an owner would then read the clock, which decision 6 of the architecture keeps out of each projection.
- **Source of the walkthrough of the check of the availability of a short code, on Sun Oct 25 2026.** The engineer requested "implement Check the availability of a short code.", and delegated the decisions of the walkthrough: "delegated". The check adds the property availability to the short code. It uses the concepts short code, link, and deletion of Part 1, and adds no concept and no association.
- **The availability of a short code is a read, and decides nothing.** The form shows it before the submission. The decision at the submission checks hard constraint 1 again, because a different person can take the short code between the check and the submission. The append condition then decides which of two submissions makes the link.
- **A short code of a deleted link is taken.** No new link gets it, by hard constraint 1. A check that gave `available` would then contradict the submission.
- **The check gives no more than the submission gives.** A submission of a short code that a link has already says that a link has it. The check says it before the submission, to each visitor and each user. It does not say whose link has the short code, or whether the link is deleted or expired.
- **Only a short code of the form of a short code is checked.** A value that is not seven letters or digits gets the error of its form, and no check.
- **Alternative that the agent did not take: a button that the page disables while the short code is taken.** The availability can change before the submission, so the submission keeps its own check. A disabled button adds a second check of the same fact, and it can be out of date.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:08:34 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:55:34 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 7:57:58 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:26:28 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:55:25 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 11:29:32 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 1:52:38 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 5:11:28 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 9:23:16 PM UTC
