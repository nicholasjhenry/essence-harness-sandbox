# Shortener

A Phoenix link shortener, built by an agent with the Essence harness.

## Set up

1. Clone the repository with its submodules. The harness and the playbook are private submodules, so you need read access to both.

   ```sh
   git clone --recurse-submodules https://github.com/nicholasjhenry/essence-harness-sandbox
   cd essence-harness-sandbox
   ```

   In a clone with no submodules, run `git submodule update --init`.

2. Install the dependencies, and make the database.

   ```sh
   mix setup
   ```

3. Start the server, and open [`localhost:4000`](http://localhost:4000).

   ```sh
   mix phx.server
   ```

## Use Essence

Start `claude` in the root of the repository. `AGENTS.md` tells the agent to read the essence before the first request.

| Path | Holds |
|---|---|
| `.essence/system/` | The harness: rules, language, kernel, and practices. Links into `.vendor/essence-harness`. |
| `.essence/local/` | The rules, practices, and work products of this system. |
| `.essence/local/endeavors/` | One directory for each endeavor, with its requirements and alpha states. |
| `.essence/local/work-products/` | The domain vocabulary, the domain model, the architecture, and the features. |

Start an endeavor with a request. Examples:

- `new endeavor: implement: Check the availability of a short code`
- `new endeavor: implement: Check the availability of a short code, completely delegated`

Developing with Sprites (optional):

- `new endeavor: implement: Check the availability of a short code, completely delegated, develop in a sprite`

The agent builds each feature by Feature-Driven Development, and commits each activity on a work branch. A delegated endeavor ends in a pull request. The agent merges a pull request only when you request the merge.

A sprite is a Fly.io machine for one endeavor. The second section of `AGENTS.md` gives its setup. You need the `sprite` CLI, and the 1Password CLI `op`.
