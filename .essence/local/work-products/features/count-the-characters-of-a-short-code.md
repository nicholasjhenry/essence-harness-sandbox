# Count the characters of a short code

**Major feature set:** Link management
**Feature set:** Shortening a target URL
**Plan position:** 2

## Milestones

| Milestone | Date reached |
|---|---|
| domain walkthrough | 2026-10-25 |
| design | 2026-10-25 |
| design inspection | 2026-10-25 |
| code | 2026-10-25 |
| code inspection | 2026-10-25 |
| integration | |

## Request

The engineer requested a visible count of the characters of the short code field, and a field that accepts no character after the limit. A short code is exactly seven letters or digits. The count therefore shows the number of characters out of 7, and the field accepts no eighth character.

## Design

A person who shortens a target URL types in the field `Short code (optional)`. Below the field, the page shows the number of characters in the field, out of 7, such as `3/7`. The count changes with each character that the person types or removes. The field accepts no eighth character, and a paste of more than seven characters keeps the first seven. The visitor page at `/` and the user page at `/user-links` each get the count and the limit.

The browser enforces the limit with the attribute `maxlength="7"` of the input. The server does not need the limit. `ShortCode.validate/2` already rejects a value that is not seven characters, so a request that ignores the attribute gets the error on the field, as before.

The server renders the count from the params of the form. The short code field loses `phx-debounce="300"`, so that each change of the field sends the `validate` event, and the page renders the new count at once. The field holds at most seven characters, so an event for each change is small. The target URL field keeps its debounce. The feature adds no JavaScript.

The count reads the value of the field in the params of the form, as the person typed it. It does not read the value of the field, because `input_value/3` of `phoenix_ecto` gives the change first, and `ShortCode.validate/2` removes the spaces at the start and the end of the change. The count is therefore the number of characters in the field, which is what the person sees. After a link is made, the page clears the form, and the count shows `0/7`.

The domain does not change. A short code is seven letters or digits, by the domain model. The number 7 comes from `ShortCode`, so the count, the limit, and the validation use one value.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.ShortCode` | `length/0` | gives the number of characters of a short code, 7, from the module attribute `@length`. |
| `ShortenerWeb.LinkComponents` | `short_code_input/1` | the short code field of a page that shortens a target URL. It takes the attribute `field`, a `Phoenix.HTML.FormField`. It renders the input with the label `Short code (optional)`, the placeholder `Summer1`, and `maxlength` from `ShortCode.length/0`. Below the input, it renders the hint `#short-code-hint`, as before, and the count `#short-code-count`, with the text `<n>/7` and `aria-live="polite"`. `<n>` is `String.length/1` of the value of the field in `field.form.params`, by the key `Atom.to_string(field.field)`, or 0 if the params hold no value. |

### Changed modules

| Module | What changes |
|---|---|
| `Shortener.Features.ShortenTargetUrlForVisitor.Live` | `render/1` calls `<.short_code_input field={@form[:short_code]} />` in place of the input and the hint. |
| `Shortener.Features.ShortenTargetUrlForUser.Live` | the same as the visitor page. |
| `ShortenerWeb.LinkComponents` | the moduledoc says that the module holds the components that show a link and the components of the form that makes a link. |

### Sequence

1. The page mounts with an empty form. `short_code_input/1` renders `0/7`.
2. The person types a character in the field. The browser sends the `validate` event with the params of the form, with no debounce.
3. The LiveView builds the changeset from the params, as before, and assigns the form.
4. `short_code_input/1` reads the value of the field from the params of the form, and renders the new count.
5. The person types a seventh character. The browser accepts no eighth character, by `maxlength`.
6. On `save`, the LiveView does as before. On a new link, it clears the form, and the count shows `0/7`. On an error, the form keeps its value, and the count shows its number of characters.

### Tests

- `ShortCode.length/0`: gives 7, and a short code from `generate/0` has that number of characters.
- The visitor page:
  - the page shows `0/7` given no short code in the field.
  - the page shows `3/7` given the change of the field to `abc`.
  - the page shows `7/7` given the change of the field to `Summer1`.
  - the page shows `4/7` given the change of the field to `abc ` with a space at the end.
  - the input of the short code has `maxlength="7"`.
  - the input of the short code has no `phx-debounce`.
  - the page shows `0/7` after a link is made with a chosen short code.
  - the page shows `3/7` and the form error given a submission of `abc`.
- The user page, with the form `#shorten-for-user-form`: the page shows `0/7`, shows `3/7` given the change of the field to `abc`, and the input has `maxlength="7"`.
- The existing tests of the two pages pass with no change.

### Design inspection

An agent in a session other than the session of the author inspected the design. It applied the elixir-testing and elixir-core skills.

The first inspection rejected the design for one blocking finding: the value of a field of a changeset form is the change, and `ShortCode.validate/2` trims the change. A field of `abc ` would show `3/7`. The design now counts the value in the params of the form, and adds a test of a value with a space at the end. The findings that do not block are:

1. Removing the debounce is sound. The format error now shows from the first character.
2. `maxlength` meets the request. `Phoenix.LiveViewTest` does not apply it, so the test of the attribute is the only proof of the limit.
3. The tests of the user page use the form `#shorten-for-user-form`.
4. `ShortenerWeb.LinkComponents` fits the component. Its moduledoc changes to cover a component of the form.

The second inspection accepted the amended design. It found that the params of the form hold string keys, after the mount, a change, an error, and a reset. Its findings do not block. The design takes both:

5. The component reads the params by the key `Atom.to_string(field.field)`, because `field.field` is an atom.
6. This section records the second verdict.

### Code inspection

An agent in a session other than the session of the author inspected the code, and accepted it. It applied the testing-names-given, elixir-testing, and elixir-core skills. `mix test` gave 185 tests with no failure in the sprite `mcp-essence-harness-sandbox`, `mix format --check-formatted` passed, and `mix compile --warnings-as-errors --force` passed. It found no blocking defect. The code takes findings 1 and 5, and `mix test` then gave 185 tests with no failure again. It does not take findings 2, 3, 4, 6, and 7:

1. `ShortCode` calls `Kernel.length/1` by its full name, so that no reader takes the calls for the new `length/0`.
2. `@length` stays a module attribute, because a guard and the regex read it.
3. The component does the design: the params by their key, `maxlength` from `ShortCode.length/0`, and `aria-live="polite"`.
4. The hint still says "Seven characters" as text. The design keeps the hint as before.
5. The name of the test of the limit drops "given the page", which states no condition.
6. One test of the user page checks the count and the limit together. They are one behavior.
7. The tests act only through `render_change` and `render_submit`, and check only with `has_element?`.

---

Authored by Nicholas Henry on Sun Oct 25 2026 at 11:21:14 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 1:32:06 PM EDT
