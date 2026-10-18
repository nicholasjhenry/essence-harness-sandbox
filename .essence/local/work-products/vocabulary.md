# Link Shortener — Domain Vocabulary

The terms of the domain of the link shortener. Each definition is a genus and a differentia, by the rules of the concept-speak practice.

## Terms

- **link shortener** — the software system of this repository. It makes a link for a target URL, and it knows each user and the plan of each user.
- **target URL** — an absolute URL, with the `http` or the `https` scheme, that a person gives to the link shortener to shorten. It differs from a short URL, which the link shortener makes.
- **short code** — an identifier of one link, made of letters and digits, that the link shortener makes. It differs from the link, which also holds a target URL.
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

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:08:34 PM EDT
