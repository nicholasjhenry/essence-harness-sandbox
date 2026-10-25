# Queue four features into the backlog

**Activity:** Build a feature list, of the feature-driven-development practice. The engineer requested four features from a brainstorm, and stated that no endeavor takes them.

## Work products

- `.essence/local/work-products/features/count-the-characters-of-a-short-code.md` — new
- `.essence/local/work-products/features/check-the-availability-of-a-short-code.md` — new
- `.essence/local/work-products/features/count-the-resolutions-of-a-link.md` — new
- `.essence/local/work-products/features/change-the-target-url-of-a-link.md` — new

## Agent skills

- feature-driven-development
- version-control
- simplified-technical-english

## Decisions

- No requirements document lists the four records. Each feature is in the backlog, and its state is Listed.
- Each feature takes a feature set that exists, and the plan position of that feature set. Count the characters of a short code and Check the availability of a short code are in Shortening a target URL, at plan position 2. Count the resolutions of a link is in Resolving a short URL, at plan position 3. Change the target URL of a link is in Maintaining a link, at plan position 6.
- Each record holds a Request section with the scope from the brainstorm, so that the domain walkthrough starts from it.
- The short code is exactly seven letters or digits. The record of Count the characters of a short code therefore states a count out of 7, and not a maximum only.
- The resolution appends no event, and the domain model states that the link shortener records no resolution. The record of Count the resolutions of a link states this. The brainstorm said that the event store records each resolution, and that was wrong.
- The domain model and the domain vocabulary do not change. Each feature acts on a concept of the domain model: short code or link. The domain walkthrough of each feature adds what the feature needs.
