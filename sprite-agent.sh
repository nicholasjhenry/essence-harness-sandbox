#!/usr/bin/env bash
#
# Starts the Claude Code session of a delegated endeavor in a sprite. The
# session runs in a TTY, so it keeps running after this script ends. The
# engineer attaches to it, and logs Claude Code in on the first attach.
#
# The prompt is sprite-agent-prompt.md, with the request of the engineer, the
# name and the URL of the sprite, and the clone filled in. The provenance
# footer of the template is not sent.
#
# Usage:
#   ./sprite-agent.sh [-o <org>] [-n] <sprite> <request>
#
#   -n  print the prompt, and start no session
#
# Run it on the computer of the engineer, from the root of the repository,
# after ./sprite-auth.sh and ./sprite-setup.sh. Requirements: the Sprites CLI
# `sprite`, logged in, and python3. The sprite needs the clone ~/app, clean,
# on main, and `claude`.

set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template="$project_root/sprite-agent-prompt.md"
clone="/home/sprite/app"

usage() {
  sed -n '11,19s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

fail() {
  echo "sprite-agent: $*" >&2
  exit 1
}

org=""
dry_run=""

while getopts ":o:nh" option; do
  case "$option" in
    o) org="$OPTARG" ;;
    n) dry_run=1 ;;
    h) usage; exit 0 ;;
    :) fail "option -$OPTARG needs a value" ;;
    *) fail "unknown option -$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

[[ $# -eq 2 ]] || { usage >&2; exit 2; }
sprite_name="$1"
request="$2"
[[ -n "$request" ]] || fail "give the request of the engineer"

command -v sprite >/dev/null || fail "the Sprites CLI 'sprite' is not installed"
command -v python3 >/dev/null || fail "python3 is not installed"
[[ -f "$template" ]] || fail "$template is not found"

sprite_args=(-s "$sprite_name")
[[ -n "$org" ]] && sprite_args+=(-o "$org")

in_sprite() {
  sprite exec "${sprite_args[@]}" --no-stdin --dir "$clone" -- "$@"
}

# The URL holds a suffix that Fly gives the sprite, so it comes from the
# sprite and not from its name.
sprite_url="$(in_sprite sprite-env info | sed -n 's/.*"sprite_url": *"\([^"]*\)".*/\1/p')"
[[ -n "$sprite_url" ]] || fail "sprite-env info of $sprite_name gives no sprite_url. Is the clone $clone set up?"

prompt="$(SPRITE="$sprite_name" SPRITE_URL="$sprite_url" CLONE="$clone" REQUEST="$request" \
  python3 - "$template" <<'PY'
import os, sys

text = open(sys.argv[1]).read()
# The provenance footer starts at the last horizontal rule.
text = text[: text.rindex("\n---\n")].rstrip() + "\n"
request = "\n".join(line.rstrip() for line in os.environ["REQUEST"].strip().splitlines())
values = {
    "{{SPRITE}}": os.environ["SPRITE"],
    "{{SPRITE_URL}}": os.environ["SPRITE_URL"],
    "{{CLONE}}": os.environ["CLONE"],
    # Each line of the request stays in the quote.
    "{{REQUEST}}": request.replace("\n", "\n> "),
}
for key, value in values.items():
    text = text.replace(key, value)
assert "{{" not in text, "the template holds a placeholder with no value"
sys.stdout.write(text)
PY
)"

if [[ -n "$dry_run" ]]; then
  printf '%s\n' "$prompt"
  exit 0
fi

# The session makes its own work branch from main, so the clone starts clean
# and on main.
[[ "$(in_sprite git branch --show-current)" == "main" ]] || fail "the clone $clone is not on main"
[[ -z "$(in_sprite git status --porcelain)" ]] || fail "the clone $clone has changes"
in_sprite sh -c 'command -v claude' >/dev/null || fail "claude is not installed in $sprite_name"

before="$(sprite sessions list "${sprite_args[@]}" 2>/dev/null | awk '$1 ~ /^[0-9]+$/ {print $1}')"

# A TTY session keeps running after its client ends. This client ends when
# the session shows in the list.
sprite exec "${sprite_args[@]}" --tty --dir "$clone" -- claude "$prompt" </dev/null >/dev/null 2>&1 &
client=$!

session=""
for _ in $(seq 1 30); do
  sleep 1
  session="$(sprite sessions list "${sprite_args[@]}" 2>/dev/null |
    awk '$1 ~ /^[0-9]+$/ && $2 == "claude" {print $1}' |
    grep -vxF -f <(printf '%s\n' "$before") | tail -1 || true)"
  [[ -n "$session" ]] && break
done

kill "$client" 2>/dev/null || true
[[ -n "$session" ]] || fail "the session of claude did not start in $sprite_name"

echo "sprite-agent: the session $session of Claude Code runs in $sprite_name, in $clone."
echo "sprite-agent: attach with: sprite attach -s $sprite_name $session"
echo "sprite-agent: on the first attach, log Claude Code in. The session then does the request."
echo "sprite-agent: the app runs at $sprite_url"
