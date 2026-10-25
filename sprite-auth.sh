#!/usr/bin/env bash
#
# Logs the GitHub CLI of a sprite in with a token from 1Password, so that the
# sprite can push its work branches and open pull requests.
#
# The token goes from `op read` to the standard input of `gh auth login` on
# the sprite. It is never an argument of a command, and it is never written
# to a local file. `gh` keeps it in `~/.config/gh` on the sprite, so the
# script runs once for each sprite, and again when the token is rotated.
#
# Usage:
#   ./sprite-auth.sh [-o <org>] [-r <op reference>] <sprite>
#
# The 1Password reference is, in order: the -r option, the variable
# SPRITE_GITHUB_TOKEN_REF, or op://Infrastructure/GitHub/credential.
#
# Run it on the computer of the engineer, from the root of the repository.
# Requirements: the 1Password CLI `op`, signed in, and the Sprites CLI
# `sprite`, logged in. The sprite needs `gh` and `git`.

set -euo pipefail

default_ref="op://Infrastructure/GitHub/credential"

usage() {
  sed -n '11,19s/^# \{0,1\}//p' "$0"
}

fail() {
  echo "sprite-auth: $*" >&2
  exit 1
}

org=""
ref="${SPRITE_GITHUB_TOKEN_REF:-$default_ref}"

while getopts ":o:r:h" option; do
  case "$option" in
    o) org="$OPTARG" ;;
    r) ref="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) fail "option -$OPTARG needs a value" ;;
    *) fail "unknown option -$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

[[ $# -eq 1 ]] || { usage >&2; exit 2; }
sprite_name="$1"

command -v op >/dev/null || fail "the 1Password CLI 'op' is not installed"
command -v sprite >/dev/null || fail "the Sprites CLI 'sprite' is not installed"

sprite_args=(-s "$sprite_name")
[[ -n "$org" ]] && sprite_args+=(-o "$org")

# Read the token first, so that a failed read stops the script before the
# sprite gets an empty input. printf is a shell builtin, so the token is not
# in the argument list of a process.
token="$(op read --no-newline "$ref")" || fail "could not read $ref from 1Password"
[[ -n "$token" ]] || fail "$ref is empty"

echo "Logging the GitHub CLI of sprite '$sprite_name' in with $ref"

# shellcheck disable=SC2016 # The single quotes keep the script for the sprite.
printf '%s\n' "$token" | sprite exec "${sprite_args[@]}" --stdin -- sh -c '
  set -e
  command -v gh >/dev/null || { echo "gh is not installed on the sprite" >&2; exit 1; }
  gh auth login --hostname github.com --git-protocol https --with-token
  gh auth setup-git --hostname github.com
  gh auth status --hostname github.com
'
unset token

echo "Done. The sprite '$sprite_name' can push to GitHub over HTTPS."
