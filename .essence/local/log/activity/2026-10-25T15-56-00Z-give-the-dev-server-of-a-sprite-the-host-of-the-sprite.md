# Give the dev server of a sprite the host of the sprite

## Activity

A change of the setup of a sprite, at the request of the engineer: "when testing on a sprite the domain is localhost, so things like the redirection do not work correctly".

## Work products

- `config/runtime.exs` — changed: in dev, `PHX_HOST` sets the URL of the endpoint to `https://<PHX_HOST>`, on port 443
- `sprite-setup.sh` — changed: the service `shortener` gets `PHX_HOST`, the host of the `sprite_url` of `sprite-env info`
- `AGENTS.md` — changed: step 3 of the setup states `PHX_HOST`

## Agent skills

- elixir-core
- simplified-technical-english
- version-control

## Decisions

- The cause: `ShortenerWeb.Endpoint.url()` gave `http://localhost:8080` in the sprite. Each short URL on a page and each login link in an email then went to `localhost`, and not to the sprite.
- The variable is `PHX_HOST`, as the prod block of `config/runtime.exs` uses it. With no `PHX_HOST`, dev on the computer of the engineer and the tests keep `localhost`.
- The scheme is `https` and the port is 443, because the proxy of the sprite serves its URL on HTTPS. The dev server still listens on port 8080.
- The script reads the host from `sprite-env info`, and does not build it from the name of the sprite, because the URL holds a suffix that Fly gives.
- The change is on the work branch `docs/give-the-url-of-the-sprite-in-the-report-of-a-delegation`, because the unit of work started on that work branch.
- The check, in the sprite `mcp-essence-harness-sandbox`: `sprite-setup.sh` ran again with no failure. The process of the dev server holds `PHX_HOST=mcp-essence-harness-sandbox-wr6.sprites.app`. `ShortenerWeb.Endpoint.url()` with that `PHX_HOST` gives `https://mcp-essence-harness-sandbox-wr6.sprites.app`. `mix test` gave 172 tests with no failure. The two files were then restored in the clone of the sprite, so that the work branch `feat/count-the-resolutions-of-a-link` holds no change of this activity.
