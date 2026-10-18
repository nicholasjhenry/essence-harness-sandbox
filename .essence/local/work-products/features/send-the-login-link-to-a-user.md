# Send the login link to a user

**Major feature set:** User management
**Feature set:** Logging in a user
**Plan position:** 4

## Milestones

| Milestone | Date reached |
|---|---|
| domain walkthrough | 2026-10-17 |
| design | 2026-10-17 |
| design inspection | 2026-10-17 |
| code | 2026-10-17 |
| code inspection | 2026-10-17 |
| integration | 2026-10-17 |

## Design

A person types an email address on the login page. The link shortener makes a login token, appends one `LoginLinkSent` event, and sends an email with the login link to the email address.

### New concepts and operations

| Module | Operation | What it does |
|---|---|---|
| `Shortener.Shared.Secret` | `generate/0`, `hash/1` | 32 random bytes from `:crypto.strong_rand_bytes/1`, in URL-safe Base64 with no padding. The hash is the SHA-256 hash, in lower-case hexadecimal. |
| `Shortener.Shared.LoginLinkSent` | `to_event/1`, `from_event/1` | the event: `email_address`, `token_hash`, and `sent_at`. The tags are `login_token:` and the token hash, and the tag of the user. |
| `Shortener.Mailer` | `deliver/1` | `use Swoosh.Mailer, otp_app: :shortener` |
| `mix.exs` and `config/` | | `{:swoosh, "~> 1.29"}`. `config.exs`: the adapter `Swoosh.Adapters.Local`, and `config :swoosh, :api_client, false`. `test.exs`: the adapter `Swoosh.Adapters.Test`. `prod.exs`: `config :swoosh, local: false`. |
| `ShortenerWeb.Router` | | `forward "/mailbox", Plug.Swoosh.MailboxPreview`, in a `/dev` scope that pipes through `:browser`, if `dev_routes` is true |
| `Shortener.Features.SendLoginLinkToUser.LoginEmail` | `new/2` | the Swoosh email to the email address, with the login link in its text body |
| `Shortener.Features.SendLoginLinkToUser.Command` | `changeset/2` | an embedded schema: `email_address`, required, validated by `EmailAddress.validate/2` |
| `Shortener.Features.SendLoginLinkToUser.CommandHandler` | `handle/3` | takes the command, the login token, and `now`. It decides on an empty decision model, appends the event, and gives `{:ok, LoginLinkSent.t()}`. |
| `Shortener.Features.SendLoginLinkToUser.Live` | LiveView at `/log-in` | the form, and the message that the email is sent |

### Sequence

1. `Live.handle_event("save", params)` applies `Command.changeset/2`.
2. `Live` makes the login token with `Secret.generate/0`, and calls `CommandHandler.handle(command, token, DateTime.utc_now())`.
3. `CommandHandler` calls `Decider.run(Shortener.EventStore, [], decide)`. No hard constraint applies to a new login token, so the decision model is empty. `decide` gives `{:ok, [LoginLinkSent.to_event(...)]}` with `Secret.hash(token)`.
4. `Live` calls `Mailer.deliver(LoginEmail.new(email_address, url(~p"/log-in/#{token}")))`.
5. `Live` shows "A login link is on its way to <email address>." and the form again.

The route is in the `:current_user` live session, which the design of "Redeem the login token of a user" adds, in the scope that pipes through `:browser`. A visitor needs it.

The page sends a login link to any email address, with no limit of rate. The final report of the endeavor names this risk.

### Tests

- The command handler: the event holds the hash of the token and not the token, and has the two tags.
- The LiveView: a valid submission shows the message, and Swoosh delivers one email to the email address with the login link. An email address with no domain shows an error, and delivers no email.

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 10:56:28 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:56:47 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 10:58:21 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:11:38 PM EDT
Changed by Nicholas Henry on Sat Oct 17 2026 at 11:13:22 PM EDT
