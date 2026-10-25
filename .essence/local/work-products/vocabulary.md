# Link Shortener — Domain Vocabulary

The terms of the domain of the link shortener. Each definition is a genus and a differentia, by the rules of the concept-speak practice.

## Terms

- **link shortener** — the software system of this repository. It makes a link for a target URL, and it knows each user and the plan of each user.
- **target URL** — an absolute URL, with the `http` or the `https` scheme, that a person gives to the link shortener to shorten, or that the owner of a link gives in a target URL change. It differs from a short URL, which the link shortener makes.
- **short code** — an identifier of one link, made of letters and digits. The link shortener makes it, or the person who shortens the target URL chooses it. It differs from the link, which also holds a target URL.
- **short URL** — a URL of the link shortener whose path is the short code of one link. It differs from the target URL of the link, which is the URL that the link refers to.
- **link** — a reference from one short code to one target URL, made by the link shortener when a person shortens the target URL. It differs from the short URL, which is how a person writes the link.
- **user** — a person whom the link shortener knows by one email address. It differs from a visitor, whom the link shortener does not know.
- **visitor** — a person who uses the link shortener without an email address. It differs from a user, whom the link shortener knows by an email address.
- **email address** — an address of the form `name@domain` that identifies one user to the link shortener. The link shortener compares two email addresses with no difference between upper case and lower case.
- **owner** — the user for whom the link shortener made a link. A link that a visitor shortens has no owner. It differs from a visitor, who is the person and not a role of the link.
- **plan** — a level of service of the link shortener, with a link limit, that applies to each user on it. It differs from a plan assignment, which is the event that puts one user on a plan.
- **link limit** — the number of links of one owner that the plan of the owner permits. A plan with no link limit permits any number of links.
- **plan assignment** — an event in which the link shortener puts one user on one plan, at one time. It differs from the plan, which exists before and after each plan assignment.
- **default plan** — the plan of a user who has no plan assignment. The default plan is the Free plan.
- **resolution** — an event in which the link shortener finds the target URL of the link of one short URL, and sends the person to that target URL. It differs from the link, which the resolution reads and does not change.
- **deletion** — an event in which the link shortener removes one link, at the request of the owner of the link. After the deletion, the short URL of the link resolves to no target URL, and no new link gets its short code. It differs from a resolution, which reads the link and does not change it.
- **expiration** — an event in which the link shortener sets the time of expiration of one link, at the request of the owner of the link. From the time of expiration, the short URL of the link resolves to no target URL, and the link still exists. It differs from a deletion, which removes the link at once.
- **time of expiration** — the time from which the short URL of one link resolves to no target URL. The latest expiration of the link gives it. A link with no expiration has no time of expiration. It differs from the time of setting, which is the time at which the owner set it.
- **time of setting** — the time at which the owner of one link requested one expiration of the link. It differs from the time of expiration, which the expiration sets.
- **target URL change** — an event in which the link shortener replaces the target URL of one link with a new target URL, at the request of the owner of the link. After the target URL change, the short URL of the link resolves to the new target URL, and the short code of the link stays the same. It differs from a deletion, which removes the link, and from a new link of the new target URL, which has a new short code.
- **login token** — a secret of one use, made by the link shortener for one email address, that lets a person log in as the user of that email address. It differs from a session token, which a browser holds after the login.
- **login link** — a URL of the link shortener whose path holds one login token, sent by email to the email address of the login token. It differs from a short URL, which refers to a target URL.
- **login session** — a period in which the link shortener knows the person at one browser as one user, from the redemption of a login token to the logout. It differs from a user, who can have zero or more login sessions.
- **session token** — a secret, held by one browser, that identifies one login session. It differs from a login token, which starts a login session and is then of no use.
- **redemption** — an event in which the link shortener accepts one login token, and starts one login session for the user of the login token. It differs from a login link, which only carries the login token.
- **logout** — an event in which the link shortener ends one login session. After the logout, its session token identifies no user.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:08:34 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:55:34 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 7:57:58 PM EDT
Changed by Nicholas Henry on Sat Oct 24 2026 at 9:55:25 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 1:52:38 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 5:11:28 PM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 5:30:00 PM EDT
