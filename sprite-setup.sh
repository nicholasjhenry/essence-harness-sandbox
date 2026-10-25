#!/usr/bin/env bash
#
# Sets up a sprite for the development of the link shortener. Run it in the
# sprite, from the root of a clone that has its submodules.
#
# The script sets the git identity, installs the dependencies of the app, and
# creates the service of the dev server. It does not log GitHub in, which
# ./sprite-auth.sh does, and it does not clone the repository. Each step can run again with no harm.
#
# Usage: ./sprite-setup.sh --name <name> --email <email>
#
#   --name <name>    the git user.name of the engineer
#   --email <email>  the git user.email of the engineer

set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
service="shortener"
port="8080"

usage() {
  sed -n '10,13s/^# \{0,1\}//p' "${BASH_SOURCE[0]}" >&2
  exit 2
}

fail() {
  echo "sprite-setup: $*" >&2
  exit 1
}

name=""
email=""

while [ $# -gt 0 ]; do
  case "$1" in
    --name) name="${2:?}"; shift 2 ;;
    --email) email="${2:?}"; shift 2 ;;
    -h|--help) usage ;;
    *) fail "unknown argument: $1" ;;
  esac
done

command -v sprite-env >/dev/null || fail "sprite-env is not found. Run this script in a sprite."
command -v mix >/dev/null || fail "mix is not found"

# Each submodule must be checked out, so that each link in .essence/system/
# and .claude/skills/ resolves.
for link in "$project_root"/.essence/system/* "$project_root"/.claude/skills/*; do
  [ -L "$link" ] || continue
  [ -e "$link" ] || fail "$link does not resolve. Run: git submodule update --init"
done

# A2. The git identity, which each commit and each provenance footer uses.

# The options are required. A new sprite has a global user.email of
# noreply@sprites.dev, which no commit of the engineer takes.
[ -n "$name" ] || fail "give the git user.name with --name"
[ -n "$email" ] || fail "give the git user.email with --email"

git config --global user.name "$name"
git config --global user.email "$email"
echo "sprite-setup: the git identity is $name <$email>."

# A4. The dependencies of the app, its database, and its assets.

cd "$project_root"
mix local.hex --force --if-missing
mix local.rebar --force --if-missing
mix setup
echo "sprite-setup: the dependencies, the database, and the assets are set up."

# A5. The service of the dev server. The proxy of the sprite routes its URL to
# the port of the service, and starts the service on a request. PHX_HOST gives
# the dev server the host of that URL, so that each URL the app makes is a URL
# of the sprite and not of localhost.

sprite_url="$(sprite-env info 2>/dev/null | sed -n 's/.*"sprite_url": *"\([^"]*\)".*/\1/p')"
[ -n "$sprite_url" ] || fail "sprite-env info gives no sprite_url"
sprite_host="${sprite_url#https://}"
sprite_host="${sprite_host%%/*}"

if sprite-env services get "$service" >/dev/null 2>&1; then
  sprite-env services delete "$service" >/dev/null
fi

sprite-env services create "$service" \
  --cmd bash \
  --args "-c,mix ecto.migrate --quiet && exec mix phx.server" \
  --env "PORT=$port,PHX_HOST=$sprite_host" \
  --dir "$project_root" \
  --http-port "$port" \
  --no-stream >/dev/null

echo "sprite-setup: the service $service runs the dev server on port $port."
echo "sprite-setup: the dev server makes each URL with the host $sprite_host."
echo "sprite-setup: open $sprite_url"
