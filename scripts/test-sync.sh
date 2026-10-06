#!/bin/sh
# Tests for scripts/sync.sh against throwaway git repos.
#
# Usage: scripts/test-sync.sh
#
# The baseline sources are copied from the working tree into a temporary
# source repo, so the tests cover uncommitted changes too.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd -P)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failures=0
current=

git_q() {
    git -c commit.gpgsign=false -c user.name=test -c user.email=test@example.com "$@"
}

commit_all() {
    git_q -C "$1" add -A
    git_q -C "$1" commit -qm "$2"
}

fail() {
    echo "FAIL [$current] $*"
    sed 's/^/    sync stderr: /' "$work/stderr" 2>/dev/null || true
    failures=$((failures + 1))
}

expect() { "$@" || fail "expected: $*"; }
expect_not() { if "$@"; then fail "did not expect: $*"; fi; }

src=$work/src
mkdir -p "$src/scripts" "$src/.github"
cp "$here/AGENTS.md" "$src/"
cp "$here/.github/pull_request_template.md" "$src/.github/"
cp -R "$here/skills" "$src/skills"
cp "$here/scripts/sync.sh" "$src/scripts/"
git_q init -q "$src"
commit_all "$src" baseline
stamp=$(git -C "$src" rev-parse --short=12 HEAD)
skills=$(cd "$src/skills" && ls -d oasis-*)

sync() { "$src/scripts/sync.sh" "$1" >/dev/null 2>"$work/stderr"; }

# new_target <name> [AGENTS.md content]: a committed repo in $t.
new_target() {
    current=$1
    t=$work/$1
    git_q init -q "$t"
    echo "readme" >"$t/README.md"
    if [ $# -gt 1 ]; then printf '%s' "$2" >"$t/AGENTS.md"; fi
    commit_all "$t" init
}

block_of() {
    awk '/^<!-- oasis-baseline:end -->$/ { f = 0 }
        f
        /^<!-- oasis-baseline:start( v=[0-9a-f]+)? -->$/ { f = 1 }' "$1"
}

same_block() {
    block_of "$src/AGENTS.md" >"$work/want"
    block_of "$1" >"$work/got"
    cmp -s "$work/want" "$work/got"
}

line_of() { grep -n -m 1 -e "$1" "$2" | cut -d: -f1; }
line_at() { sed -n "$1p" "$2"; }

# The target's git status must not change when sync refuses.
expect_refusal() {
    before=$(git -C "$t" status --porcelain)
    if sync "$t"; then fail "sync succeeded"; fi
    expect test "$before" = "$(git -C "$t" status --porcelain)"
}

new_target fresh
expect sync "$t"
f=$t/AGENTS.md
expect grep -qx "<!-- oasis-baseline:start v=$stamp -->" "$f"
expect same_block "$f"
expect grep -qx '## This repository' "$f"
expect test "$(cat "$t/CLAUDE.md")" = "@AGENTS.md"
expect cmp -s "$src/.github/pull_request_template.md" \
    "$t/.github/pull_request_template.md"
for s in $skills; do
    expect cmp -s "$src/skills/$s/SKILL.md" "$t/.agents/skills/$s/SKILL.md"
    expect test -L "$t/.claude/skills/$s"
    expect test -f "$t/.claude/skills/$s/SKILL.md"
done
commit_all "$t" synced
expect sync "$t"
expect test -z "$(git -C "$t" status --porcelain)"

new_target intro '# Demo

Intro line one.
Intro line two.

## Commands

run it
'
expect sync "$t"
f=$t/AGENTS.md
expect same_block "$f"
start=$(line_of '^<!-- oasis-baseline:start' "$f")
end=$(line_of '^<!-- oasis-baseline:end' "$f")
expect test "$(line_at $((start - 1)) "$f")" = ""
expect test "$(line_at $((start - 2)) "$f")" = "Intro line two."
expect test "$(line_at $((end + 1)) "$f")" = ""
expect test "$(line_at $((end + 2)) "$f")" = "## Commands"
expect grep -qx 'run it' "$f"

new_target intro-blanks '# Demo

Intro.


## Commands
'
expect sync "$t"
f=$t/AGENTS.md
end=$(line_of '^<!-- oasis-baseline:end' "$f")
expect test "$(line_at $((end + 1)) "$f")" = ""
expect test "$(line_at $((end + 2)) "$f")" = "## Commands"

new_target heading '# Demo
## Commands
'
expect sync "$t"
f=$t/AGENTS.md
start=$(line_of '^<!-- oasis-baseline:start' "$f")
end=$(line_of '^<!-- oasis-baseline:end' "$f")
expect test "$start" = 3
expect test "$(line_at 2 "$f")" = ""
expect test "$(line_at $((end + 1)) "$f")" = ""
expect test "$(line_at $((end + 2)) "$f")" = "## Commands"

new_target no-h1 'Some notes.
'
expect sync "$t"
f=$t/AGENTS.md
expect test "$(line_of '^<!-- oasis-baseline:start' "$f")" = 1
expect test "$(tail -n 1 "$f")" = "Some notes."

new_target replace '# Demo

Wrap the baseline in `<!-- oasis-baseline:start -->` markers.

<!-- oasis-baseline:start v=0123abcd -->
old rule
<!-- oasis-baseline:end -->

## This repository

keep me
'
expect sync "$t"
f=$t/AGENTS.md
expect same_block "$f"
expect grep -qx "<!-- oasis-baseline:start v=$stamp -->" "$f"
expect_not grep -q 'old rule' "$f"
expect grep -qF 'Wrap the baseline in `<!-- oasis-baseline:start -->` markers.' "$f"
expect grep -qx 'keep me' "$f"

new_target stale-skill
mkdir -p "$t/.agents/skills/oasis-old" "$t/.agents/skills/other" "$t/.claude/skills"
echo old >"$t/.agents/skills/oasis-old/SKILL.md"
echo other >"$t/.agents/skills/other/SKILL.md"
ln -s ../../.agents/skills/oasis-old "$t/.claude/skills/oasis-old"
commit_all "$t" skills
expect sync "$t"
expect_not test -e "$t/.agents/skills/oasis-old"
expect_not test -L "$t/.claude/skills/oasis-old"
expect test -f "$t/.agents/skills/other/SKILL.md"

new_target old-template
mkdir -p "$t/.github"
printf '<!-- oasis-baseline: synced from oasis-agentic-dev; edit it there. -->\n## Old\n' \
    >"$t/.github/pull_request_template.md"
commit_all "$t" template
expect sync "$t"
expect cmp -s "$src/.github/pull_request_template.md" \
    "$t/.github/pull_request_template.md"

new_target claude-md
echo "Use plan mode." >"$t/CLAUDE.md"
commit_all "$t" claude
expect_refusal

new_target own-template
mkdir -p "$t/.github"
echo "## Summary" >"$t/.github/PULL_REQUEST_TEMPLATE.md"
commit_all "$t" template
expect_refusal

new_target unbalanced '# Demo

<!-- oasis-baseline:start -->
'
expect_refusal

new_target duplicate '<!-- oasis-baseline:start -->
<!-- oasis-baseline:end -->
<!-- oasis-baseline:start -->
<!-- oasis-baseline:end -->
'
expect_refusal

new_target skill-dir
mkdir -p "$t/.claude/skills/oasis-review"
echo mine >"$t/.claude/skills/oasis-review/SKILL.md"
commit_all "$t" skill
expect_refusal

new_target dirty
echo wip >"$t/wip.txt"
expect_refusal

current=self
t=$src
if sync "$src"; then fail "sync into its own source succeeded"; fi

if [ "$failures" -eq 0 ]; then
    echo "sync tests passed"
else
    echo "$failures sync test failure(s)"
    exit 1
fi
