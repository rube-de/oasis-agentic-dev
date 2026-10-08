#!/bin/sh
# Run a skill eval in a throwaway repo that has the baseline synced in.
#
# Usage: tests/evals/run.sh <skill> <claude|codex> [output-file]
#
# Each tests/evals/<skill>/expected.md says what a good run shows. Agent
# output is nondeterministic: compare it with expected.md by reading it, not
# by grepping. Sync copies the committed baseline, so commit changes first.
set -eu

usage="usage: run.sh <oasis-review|oasis-design-doc> <claude|codex> [output-file]"
skill=${1:?$usage}
agent=${2:?$usage}
case $skill in oasis-review | oasis-design-doc) ;; *) echo "$usage" >&2; exit 1 ;; esac
case $agent in claude | codex) ;; *) echo "$usage" >&2; exit 1 ;; esac
here=$(cd "$(dirname "$0")" && pwd -P)
root=$(cd "$here/../.." && pwd -P)
repo=$(mktemp -d)/shop
out=${3:-$repo.$skill.md}

git_q() {
    git -c commit.gpgsign=false -c user.name=test -c user.email=test@example.com "$@"
}

commit_all() {
    git_q -C "$repo" add -A
    git_q -C "$repo" commit -qm "$1"
}

git_q init -q -b main "$repo"
cp -R "$here/shop/." "$repo/"
commit_all "Add pricing module"
"$root/scripts/sync.sh" "$repo" >/dev/null
commit_all "Adopt the Oasis baseline"

case $skill in
oasis-review)
    # A branch with the problems listed in oasis-review/expected.md.
    git_q -C "$repo" switch -q -c feature/discount
    cp -R "$here/oasis-review/change/." "$repo/"
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
    ;;
oasis-design-doc)
    # A request that meets the design-doc trigger and leaves out the why.
    prompt="Use the oasis-design-doc skill. We want customers to be able to enter a discount code at checkout."
    ;;
esac

# Read-only in both agents. dontAsk denies every tool not listed, so Claude
# Code cannot edit the fixture or write plan files into ~/.claude/plans.
# Codex can answer across several messages, so keep its whole transcript.
case $agent in
claude)
    (cd "$repo" && claude -p "$prompt" --permission-mode dontAsk \
        --allowedTools "Bash(git:*)" Read Grep Glob Skill) >"$out"
    ;;
codex)
    codex exec --cd "$repo" --sandbox read-only --ephemeral \
        --output-last-message "$out" "$prompt" >/dev/null 2>"$out.log"
    echo "transcript:   $out.log"
    ;;
esac

echo "fixture repo: $repo"
echo "output:       $out"
echo "expected:     $here/$skill/expected.md"
