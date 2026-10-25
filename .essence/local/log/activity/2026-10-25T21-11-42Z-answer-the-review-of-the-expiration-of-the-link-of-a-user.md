# Answer the review of the expiration of the link of a user

## Activity

The agent answered the review of pull request 9 by the engineer. The engineer requested "check and comments on the PR to resolve". The review has findings F1 to F3, and states that none of them blocks the merge.

## Work products

- `.essence/local/work-products/vocabulary.md` — changed: the term **time of setting** is added, and the term **time of expiration** refers to it
- `.essence/local/work-products/domain-model.md` — changed: the property and hard constraint 10 of an expiration use **time of setting**
- `lib/shortener/features/list_links_of_user/live.ex` — changed: the action of a row is `Change expiration` given a later time of expiration
- `test/shortener/features/list_links_of_user/live_test.exs` — changed: the tests check the text of the action
- `.essence/local/work-products/features/expire-the-link-of-a-user.md` — changed: the design and the tests of the list state the two texts of the action

## Agent skills

- elixir-core, elixir-testing, and testing-names-given
- concept-speak, for the new term
- simplified-technical-english

## Decisions

1. F1 is fixed. The review recommends "Time of setting", and states that F1 is "the only one to fix first". The term follows the term time of shortening. The field `set_at` keeps its name, because it already gives the time of setting.
2. F2 is not changed. The review calls it "a usability cost, not a bug", and the domain model records the entry of the time in UTC as a decision of the walkthrough, under the delegation: "delegated".
3. F3 is fixed in part. The action reads `Expire` given no expiration, and `Change expiration` given a later time of expiration. The time of the comparison is not changed. The review states "The module documentation states this behaviour, and nothing breaks", and the design states the limit.
4. `mix test` gave 228 tests with no failure. `mix format --check-formatted` and `mix compile --warnings-as-errors --force` passed.
