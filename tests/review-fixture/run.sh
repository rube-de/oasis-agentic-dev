#!/bin/sh
# Build a repo with a seeded diff and run oasis-review self mode on it.
#
# Usage: tests/review-fixture/run.sh <claude|codex> [output-file]
#
# Syncs the committed baseline into a throwaway repo, so commit your changes
# first. Agent output is nondeterministic: compare it with expected.md by
# reading it, not by grepping.
set -eu

agent=${1:?usage: run.sh <claude|codex> [output-file]}
here=$(cd "$(dirname "$0")" && pwd -P)
root=$(cd "$here/../.." && pwd -P)
repo=$(mktemp -d)/shop
out=${2:-$repo.review.md}

git_q() {
    git -c commit.gpgsign=false -c user.name=test -c user.email=test@example.com "$@"
}

commit_all() {
    git_q -C "$repo" add -A
    git_q -C "$repo" commit -qm "$1"
}

git_q init -q -b main "$repo"
cp -R "$here/base/." "$repo/"
commit_all "Add pricing module"
"$root/scripts/sync.sh" "$repo" >/dev/null
commit_all "Adopt the Oasis baseline"

git_q -C "$repo" switch -q -c feature/discount
cp -R "$here/change/." "$repo/"
{
    echo '"""Tax rate per sales region."""'
    echo
    echo "REGION_TAX_RATES = {"
    i=1
    while [ "$i" -le 600 ]; do
        printf '    "region-%03d": %d,\n' "$i" $((i % 25))
        i=$((i + 1))
    done
    echo "}"
} >"$repo/regions.py"
commit_all "Add discounts and regional tax rates"

prompt="Use the oasis-review skill in self mode on this branch; its parent is main. Report the findings, then stop: do not edit any file."
case $agent in
claude)
    (cd "$repo" && claude -p "$prompt" --permission-mode plan \
        --allowedTools "Bash(git:*)" Read Grep Glob Skill) >"$out"
    ;;
codex)
    codex exec --cd "$repo" --sandbox read-only --ephemeral \
        --output-last-message "$out" "$prompt" >/dev/null
    ;;
*)
    echo "unknown agent: $agent (use claude or codex)" >&2
    exit 1
    ;;
esac

echo "fixture repo: $repo"
echo "review:       $out"
echo "expected:     $here/expected.md"
