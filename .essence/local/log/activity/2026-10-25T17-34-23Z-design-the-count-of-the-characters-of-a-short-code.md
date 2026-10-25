# Design the count of the characters of a short code

## Activity

Design by feature, of the feature-driven-development practice, for the feature Count the characters of a short code. The feature reached the milestones domain walkthrough, design, and design inspection.

## Work products

- `.essence/local/work-products/features/count-the-characters-of-a-short-code.md` — changed: the milestone dates, the Design section, and the Design inspection section

## Agent skills

- feature-driven-development
- elixir-testing and elixir-core, applied by the inspector
- simplified-technical-english

## Decisions

1. The entry criteria hold. Feature Planned: the feature record holds plan position 2, and `.essence/local/endeavors/2026-10-25T17-30-48Z-count-the-characters-of-a-short-code/requirements.md` lists it. Software System Architecture Selected: the adoption record `2026-10-25T17-31-09Z-software-system-1-architecture-selected.md` of the endeavor.
2. The domain walkthrough with the engineer rests on the delegation: "delegated". The part of the domain is the short code. The domain model states that a short code is seven letters or digits, so the domain vocabulary and the domain model do not change.
3. The browser enforces the limit with `maxlength`. The server keeps the validation of `ShortCode.validate/2`, and adds no limit.
4. The server renders the count from the params of the form. The short code field loses its debounce, so that the count changes with each character. The feature adds no JavaScript.
5. The count, the limit, and the validation take the number 7 from the new operation `ShortCode.length/0`.
6. One component, `ShortenerWeb.LinkComponents.short_code_input/1`, renders the field on the two pages.
7. The required practice "Inspect the design of a feature" is not met by an installed practice. The skills evaluated: code-review, elixir-testing, elixir-core. code-review reviews a diff and not a design. The substitute is an inspection by a new agent session that did not write the design, with the elixir-testing and elixir-core skills. It gives the acceptance or the rejection of the design, by an inspector who is not its author, in the activity space Shape the System.
8. The first inspection rejected the design: the value of a field of a changeset form is the trimmed change. The design now counts the params. The second inspection accepted it. Each finding and what the design takes is in the Design inspection section of the feature record.
9. The inspection by an agent in place of the engineer rests on the delegation. No entry criterion was overridden.
