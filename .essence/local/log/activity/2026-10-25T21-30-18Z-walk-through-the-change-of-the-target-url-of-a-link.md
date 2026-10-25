# Walk through the change of the target URL of a link

## Activity

Design by feature, of the feature-driven-development practice: the domain walkthrough milestone of the feature Change the target URL of a link.

## Work products

- `.essence/local/work-products/domain-model.md` — changed. It adds the concept target URL change, the association of a link with its target URL changes, hard constraints 12 to 14, and the notes of the walkthrough.
- `.essence/local/work-products/vocabulary.md` — changed. It defines target URL change, and the definition of target URL names the target URL change.
- `.essence/local/work-products/features/change-the-target-url-of-a-link.md` — changed. It records the date of the domain walkthrough milestone, and the request of the engineer.

## Agent skills

- feature-driven-development — design by feature, the domain walkthrough.
- concept-speak — the definition of target URL change, as a genus and a differentia.
- simplified-technical-english — the prose of each document.
- version-control — the commit.

## Decisions

The engineer delegated the decisions of the walkthrough: "delegated". The domain walkthrough milestone needs the engineer to walk through the domain. The walkthrough rests on the delegation, and on the request of the feature record: "The owner of a link changes its target URL, and the short code stays the same." The agent took the recommended option for each open question:

1. Only the owner changes the target URL, through the login session. Hard constraint 12.
2. The new target URL must not be the target URL that the link has. Hard constraint 13. An event that changes nothing is not recorded.
3. A link whose time of expiration is past gets no target URL change. Hard constraint 14, by the same reason as hard constraint 11.
4. A deleted link, a link of a visitor, and a link of a different user get the answer of a short code of no link.
5. The short code, the time of shortening, the owner, the time of expiration, and the resolutions do not change. A resolution keeps the target URL to which it sent the person.
6. The owner changes the target URL from the list of the links of the user.
7. The concept is named target URL change. It is an event, as a deletion and an expiration are.
8. Alternatives not taken: a history of the earlier target URLs, a change of the short code, and a change that starts a link whose time of expiration is past again.
