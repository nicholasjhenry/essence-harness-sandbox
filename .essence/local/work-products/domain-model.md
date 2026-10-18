# Link Shortener — Domain Model

The properties and the associations of each concept of the domain vocabulary, in `.essence/local/work-products/vocabulary.md`. This model does not define a concept again. It has two parts of the domain.

## Part 1. Links

### Link

- **Properties:**
  - short code — exactly one. No two links have the same short code.
  - target URL — exactly one.
  - time of shortening — exactly one. The time at which the link shortener made the link.
- **Associations:**
  - a link has zero or one owner, who is a user.
  - a link is written as exactly one short URL.

### Short code

- **Properties:**
  - characters — seven letters or digits, from `A`–`Z`, `a`–`z`, and `0`–`9`.
- **Associations:**
  - a short code identifies exactly one link.

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

## Hard constraints

1. The short code of a new link must not be the short code of a link that exists.
2. The number of links of an owner must not be more than the link limit of the plan of the owner.
3. A plan assignment must not put a user on the plan that the user is on.

## Notes

- **Source of the walkthrough.** The engineer walked through the domain in the request of the session on Sat Oct 17 2026: "shorten a link", "shorten a link for a user", and "assign a plan to the user". The engineer then approved the plans Free, with a link limit of 10, and Pro, with no link limit, and the identification of a user by email address.
- **A user is known by email address, with no registration.** A user exists for the link shortener from the first link or the first plan assignment for the email address. Registration and login are not in the request. The engineer approved this decision.
- **A link of a visitor has no link limit.** The request names a plan only for a user. A limit for visitors is not in the request.
- **The default plan is Free.** A user with no plan assignment is on a plan, so that constraint 2 applies to each user.
- **A change to a plan with a smaller link limit is permitted.** A user with 12 links can go from Pro to Free. Constraint 2 then stops each new link of the user, and keeps the 12 links that exist.
- **The plans are fixed.** The request names no feature that adds or changes a plan. The two plans are a part of the link shortener, and not of its data.
- **The short code is made by the link shortener.** The request names no custom short code. Seven characters from 62 give about 3.5 × 10¹² short codes.
- **Alternative that the agent did not take: one link for each target URL.** Two shortenings of the same target URL give two links. One link for each target URL would make the link of one user the link of a different user, with a different owner.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:08:34 PM EDT
