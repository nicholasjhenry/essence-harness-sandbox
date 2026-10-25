# Check the availability of a short code

**Major feature set:** Link management
**Feature set:** Shortening a target URL
**Plan position:** 2

## Milestones

| Milestone | Date reached |
|---|---|
| domain walkthrough | 2026-10-25 |
| design | 2026-10-25 |
| design inspection | 2026-10-25 |
| code | |
| code inspection | |
| integration | |

## Request

The form shows whether a link has the chosen short code, before the person submits the form. The check at the submission stays, because the append condition decides when two people submit the same short code at the same time.

## Design

A person who shortens a target URL types a short code in the field `Short code (optional)`. When the field holds seven letters or digits, the page shows the availability of the short code below the field: `No link has this short code.` or `A link has this short code. Choose a different short code.` The page shows nothing for an empty field, or for a value that does not have the form of a short code. That value gets the error of its form, as before. The visitor page at `/` and the user page at `/user-links` each get the check.

The check is a read. It reads the events of the tag of the short code through the projection `ShortCodeClaimed`, which the decision of each shortening also reads. A short code of a link, or of a deleted link, is taken, so the check and the submission give the same answer for the same events. The check appends nothing, and the command handlers of the two shortening slices do not change. The submission keeps its own check, because a different person can take the short code between the check and the submission.

The check runs on each `validate` event. The short code field sends the event for each change, with no debounce, from the feature Count the characters of a short code. The target URL field sends it too, after its debounce of 300 ms, and the check then reads the events again. The check reads the change of the field, with the spaces at the start and the end removed. That is the short code that a submission uses.

The `save` event sets the availability again. After a new link, the form is empty, and the availability is `nil`. After the error of a short code that a link has, the error on the field tells the person the result, and the availability is `nil`. After a different error of the decision, the flash tells the result, and the availability is `nil`. After an error of the form, such as a target URL with no scheme, the decision did not run, so the page checks the short code again.

The module of the check is in `lib/shortener/shared/`, because the two shortening slices need it, by decision 5 of the architecture. The feature has no slice of its own, as the feature Count the characters of a short code has none.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.ShortCodeAvailability` | `check/1` | `@spec check(String.t() \| nil) :: :available \| :taken \| nil`. It takes a short code, or `nil`. It gives `:available` if no link has the short code and no deleted link had it, or `:taken`. It builds a decision model of one projection, `ShortCodeClaimed.new(short_code)`, with `DecisionModel.build(Shortener.EventStore, claimed: ...)`, and does not use the append condition. `nil`, and a value that `ShortCode.valid?/1` rejects, give `nil`, and read nothing. Function clauses, and no `if`, select the cases. |
| `ShortenerWeb.LinkComponents` | `short_code_input/1` | takes the new attribute `availability`: `:available`, `:taken`, or `nil`, with the default `nil`. Below the hint and the count, it renders the element `#short-code-availability`, with `aria-live="polite"`, in each case. The element holds `No link has this short code.` for `:available`, in the success color, and `A link has this short code. Choose a different short code.` for `:taken`, in the error color. For `nil`, it is empty. |

### Changed modules

| Module | What changes |
|---|---|
| `Shortener.Features.ShortenTargetUrlForVisitor.Live` | `mount/3` assigns `availability: nil`. The `validate` event assigns `ShortCodeAvailability.check(Ecto.Changeset.get_change(changeset, :short_code))`. The `save` event assigns `availability: nil` on a new link and on an error of the decision. On an error of the form, it assigns `ShortCodeAvailability.check/1` of the change of the field. `render/1` gives `availability={@availability}` to `short_code_input/1`. |
| `Shortener.Features.ShortenTargetUrlForUser.Live` | the same as the visitor page. |

### Sequence

1. The page mounts with an empty form and no availability.
2. The person types in the short code field. The browser sends the `validate` event with the params of the form.
3. The LiveView builds the changeset from the params, as before. `ShortCode.validate/2` removes the spaces at the start and the end of the change, and adds the error of the form to a value that is not seven letters or digits.
4. The LiveView calls `ShortCodeAvailability.check/1` with the change of the field. A change that is not a short code gives `nil`, with no read. A short code gives `:available` or `:taken`, from the events of the tag of the short code.
5. The LiveView assigns the form and the availability. `short_code_input/1` renders the message of the availability.
6. The person submits the form. The LiveView decides as before, and sets the availability by the result. A short code that a link took after the check gets the error on the field, as before.

### Tests

The test names take the given convention: the outcome first, then the condition after "given". A test for no availability checks that `#short-code-availability` holds no text, because `No link has this short code.` holds the text `link has this short code`.

- `test/shortener/shared/short_code_availability_test.exs`, describe "checking the availability of a short code":
  - gives `:available` given a short code that no link has.
  - gives `:taken` given a short code that a link has.
  - gives `:taken` given a short code of a deleted link.
  - gives `:available` given a short code that differs only in case from the short code of a link.
  - gives `nil` given `nil`.
  - gives `nil` given a value of three characters, and given a value with a dash.
- The visitor page, describe "checking the availability of the short code on the page":
  - shows no availability given the page on mount.
  - shows that no link has the short code given a change of the field to a free short code.
  - shows that a link has the short code given a change of the field to the short code of a link.
  - shows the availability of the short code without its spaces given a change of the field to ` Summer1 `.
  - shows no availability given a change of the field to `abc`.
  - shows the error on the field given a submission of a short code that a link took after the check. The test makes the link with the command handler of the visitor between `render_change` and `render_submit`.
  - shows no availability given a new link with a chosen short code.
  - keeps the availability given a submission with a target URL that has no scheme.
- The user page, with the form `#shorten-for-user-form`: shows that a link has the short code given the short code of a link of a visitor, and shows that no link has the short code given a free short code.
- The existing tests of the two pages pass with no change.

### Design inspection

An agent in a session other than the session of the author inspected the design, and accepted it. It applied the elixir-core, elixir-testing, and testing-names-given skills. It found no blocking defect. The design takes findings 1, 2, 4, 5, and 6. It does not take findings 3 and 7:

1. A submission with an error of the form cleared the availability, and the decision did not run. The page now checks the short code again after an error of the form.
2. The target URL field also sends the `validate` event, so the check runs again. The design now states it.
3. ` Summer1 ` is nine characters, and the browser accepts seven. A trimmed short code always has seven characters, so each value with a space that a browser can send is not a short code. The test keeps ` Summer1 `, as the test of the chosen short code does.
4. `No link has this short code.` holds `link has this short code`. A test for no availability checks for an empty element.
5. The tests take the given convention, `check/1` has a spec, and function clauses select its cases.
6. The test of a short code that a link took after the check makes the link with the command handler of the visitor.
7. The user page has two tests. The code of the two pages is the same.

---

Authored by Nicholas Henry on Sun Oct 25 2026 at 11:21:14 AM EDT
Changed by Nicholas Henry on Sun Oct 25 2026 at 9:23:59 PM UTC
