#!/bin/sh
# Copy the Oasis baseline into another repository's working tree.
#
# Usage: scripts/sync.sh <target-checkout>
#
# Writes the AGENTS.md block, the CLAUDE.md shim, the PR template and the
# oasis-* skills. Every check runs before the first write, so a failed sync
# leaves the target untouched. It never commits: review the diff, then open a
# PR in the target repo.
set -eu

START_RE='^<!-- oasis-baseline:start( v=[0-9a-f]+)? -->$'
END_RE='^<!-- oasis-baseline:end -->$'
TEMPLATE=.github/pull_request_template.md
TEMPLATE_MARK='oasis-baseline: synced from oasis-agentic-dev'

die() {
    echo "sync: $*" >&2
    exit 1
}

warn() {
    echo "sync: warning: $*" >&2
}

# Print "start end" line numbers of the marker pair in $1, nothing when the
# file has no markers, and fail on duplicates or a pair out of order.
markers() {
    awk -v s="$START_RE" -v e="$END_RE" '
        $0 ~ s { ns++; sl = NR }
        $0 ~ e { ne++; el = NR }
        END {
            if (ns == 0 && ne == 0) exit 0
            if (ns != 1 || ne != 1 || sl > el) exit 1
            print sl, el
        }' "$1"
}

[ $# -eq 1 ] || die "usage: sync.sh <target-checkout>"
src=$(cd "$(dirname "$0")/.." && pwd -P)
target=$(cd "$1" 2>/dev/null && pwd -P) || die "no such directory: $1"

# Preflight.

[ "$target" != "$src" ] || die "target is the source repo"
git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    die "not a git work tree: $target"
[ -z "$(git -C "$src" status --porcelain --untracked-files=no)" ] ||
    die "source has uncommitted changes; commit them so the stamp names them"
[ -z "$(git -C "$target" status --porcelain)" ] ||
    die "target has uncommitted or untracked changes: $target"

src_pos=$(markers "$src/AGENTS.md") && [ -n "$src_pos" ] ||
    die "source AGENTS.md needs exactly one oasis-baseline marker pair"

target_pos=
if [ -f "$target/AGENTS.md" ]; then
    target_pos=$(markers "$target/AGENTS.md") ||
        die "target AGENTS.md has duplicate or misordered oasis-baseline markers"
fi

if [ -e "$target/CLAUDE.md" ] && [ "$(cat "$target/CLAUDE.md")" != "@AGENTS.md" ]; then
    die "target CLAUDE.md has its own content; move it into AGENTS.md and" \
        "leave CLAUDE.md as the single line @AGENTS.md"
fi

# GitHub reads PR templates from the root, docs/ and .github/, any case.
templates=$(find "$target" "$target/docs" "$target/.github" -maxdepth 1 \
    -iname 'pull_request_template*' 2>/dev/null || true)
ifs=$IFS
IFS='
'
for t in $templates; do
    if [ "$t" = "$target/$TEMPLATE" ] && grep -qF "$TEMPLATE_MARK" "$t"; then
        continue
    fi
    die "target has its own PR template ($t); merge it with $TEMPLATE by hand"
done
IFS=$ifs

# Either .claude/skills links to .agents/skills as a whole, or each skill in it
# is a symlink into .agents/skills.
shared=
if [ -L "$target/.claude/skills" ]; then
    resolved=$(cd "$target/.claude/skills" 2>/dev/null && pwd -P) || resolved=
    agents=$(cd "$target/.agents/skills" 2>/dev/null && pwd -P) || agents=
    [ -n "$resolved" ] && [ "$resolved" = "$agents" ] ||
        die ".claude/skills is a symlink to somewhere other than .agents/skills"
    shared=1
else
    for link in "$target"/.claude/skills/oasis-*; do
        if [ -d "$link" ] && [ ! -L "$link" ]; then
            die "$link is a directory; it must be a symlink into .agents/skills"
        fi
    done
fi

stamp=$(git -C "$src" rev-parse --short=12 HEAD)
default=$(git -C "$src" symbolic-ref -q --short refs/remotes/origin/HEAD || true)
if [ -n "$default" ] && ! git -C "$src" merge-base --is-ancestor HEAD "$default"; then
    warn "source commit $stamp is not on $default; after a squash merge the" \
        "stamp will not resolve"
fi

# Write.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

set -- $src_pos
{
    echo "<!-- oasis-baseline:start v=$stamp -->"
    awk -v s="$1" -v e="$2" 'NR > s && NR < e' "$src/AGENTS.md"
    echo "<!-- oasis-baseline:end -->"
} >"$tmp/block"

if [ ! -f "$target/AGENTS.md" ]; then
    {
        printf '# %s\n\n' "$(basename "$target")"
        cat "$tmp/block"
        printf '\n## This repository\n\n'
        printf 'Overview, build and test commands, layout, repo-specific rules.\n'
    } >"$tmp/AGENTS.md"
elif [ -n "$target_pos" ]; then
    set -- $target_pos
    awk -v s="$1" -v e="$2" -v blk="$tmp/block" '
        NR == s { while ((getline line < blk) > 0) print line; next }
        NR > s && NR <= e { next }
        { print }' "$target/AGENTS.md" >"$tmp/AGENTS.md"
elif grep -q '^# ' "$target/AGENTS.md"; then
    # After the H1 and its intro paragraph, before the first section, with
    # exactly one blank line on each side of the block.
    awk -v blk="$tmp/block" '
        function out(s) { print s; blank = (s ~ /^[ \t]*$/) }
        function emit(trailing) {
            if (!blank) out("")
            while ((getline line < blk) > 0) out(line)
            if (trailing) out("")
            done = 1
            fresh = trailing
        }
        done && fresh && /^[ \t]*$/ { fresh = 0; next }
        done { fresh = 0; out($0); next }
        state == 0 { out($0); if ($0 ~ /^# /) state = 1; next }
        state == 1 && /^[ \t]*$/ { out($0); next }
        state == 1 && /^#/ { emit(1); out($0); next }
        state == 1 { out($0); state = 2; next }
        state == 2 && /^[ \t]*$/ { emit(1); next }
        state == 2 && /^#/ { emit(1); out($0); next }
        { out($0) }
        END { if (!done) emit(0) }' \
        "$target/AGENTS.md" >"$tmp/AGENTS.md"
else
    { cat "$tmp/block"; echo; cat "$target/AGENTS.md"; } >"$tmp/AGENTS.md"
fi
cp "$tmp/AGENTS.md" "$target/AGENTS.md"

[ -e "$target/CLAUDE.md" ] || echo "@AGENTS.md" >"$target/CLAUDE.md"

mkdir -p "$target/.github"
cp "$src/$TEMPLATE" "$target/$TEMPLATE"

mkdir -p "$target/.agents/skills" "$target/.claude/skills"
for dir in "$src"/skills/oasis-*; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    rm -rf "$target/.agents/skills/$name"
    cp -R "$dir" "$target/.agents/skills/$name"
    [ -z "$shared" ] || continue
    rm -f "$target/.claude/skills/$name"
    ln -s "../../.agents/skills/$name" "$target/.claude/skills/$name"
done
# The repo may own oasis-* skills too, so name leftovers instead of deleting.
for path in "$target"/.agents/skills/oasis-*; do
    [ -d "$path" ] || continue
    name=$(basename "$path")
    [ -d "$src/skills/$name" ] ||
        warn "$name is not a baseline skill; if it was one, remove it by hand"
done

lines=$(wc -l <"$target/AGENTS.md" | tr -d ' ')
[ "$lines" -le 200 ] || warn "AGENTS.md is $lines lines; the budget is 200"
echo "synced baseline $stamp into $target (AGENTS.md: $lines lines)"
echo "next: fill in '## This repository', review git diff, open a PR"
