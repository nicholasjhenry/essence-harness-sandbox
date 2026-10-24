# Queue the link-management and custom-short-code features into the backlog

The engineer requested two product features to queue: link management for users (list, delete, and expire their own links), and custom short codes. The activity added them to the feature list as backlog records, by the Build a feature list process of the feature-driven-development practice. It listed them in no requirements document, so each feature is Listed.

## Work products

- `.essence/local/work-products/features/list-the-links-of-a-user.md` — made.
- `.essence/local/work-products/features/delete-the-link-of-a-user.md` — made.
- `.essence/local/work-products/features/expire-the-link-of-a-user.md` — made.
- `.essence/local/work-products/features/choose-the-short-code-of-a-link.md` — made.

## Agent skills

No agent skill other than an installed practice was used. The activity applied the feature-driven-development practice for the feature list, the concept-speak practice for the names, and the simplified-technical-english practice for the prose.

## Decisions

- The activity divided "link management for users" into three features, one for each step the engineer named: List the links of a user, Delete the link of a user, and Expire the link of a user. Each is one step of one business activity.
- The activity put the three features in a new feature set, Maintaining a link, in the Link management major feature set. The business activity is a user who maintains the user's own links, which is apart from Shortening a target URL and Resolving a short URL.
- The activity made "custom short codes" the feature Choose the short code of a link, in the Shortening a target URL feature set of the Link management major feature set. A user who chooses the short code does so as a step of shortening.
- Each feature name takes the feature template with a concept of the domain model: user for the three maintenance features, and link for the short-code feature.
- The activity listed each record in no requirements document, so each feature is in the backlog and is Listed. No endeavor tracks them yet.
- The activity scoped the custom short code to a user, not a visitor, because the engineer named it among product features for users. A domain walkthrough can widen the scope.
- The activity deferred three domain decisions to a domain walkthrough, before these features are planned and designed: the meaning of a link deletion, the meaning of a link expiry, and a short code that a user chooses rather than one the link shortener makes. The current domain vocabulary defines a short code as one the link shortener makes, and defines no deletion and no expiry of a link.
