set shell := ["sh", "-eu", "-c"]

# List recipes
default:
    @just --list

# Lint Markdown, the AGENTS.md line budgets and the skills
lint: lint-markdown lint-budgets lint-skills

[private]
lint-markdown:
    npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#.claude" "#.agents" "#CLAUDE.md" "#.github/pull_request_template.md"

# Baseline block at most 80 lines, AGENTS.md at most 200 (design doc 0001).
[private]
lint-budgets:
    #!/bin/sh
    set -eu
    block=$(awk '/^<!-- oasis-baseline:end -->$/ { f = 0 } f { n++ } /^<!-- oasis-baseline:start( v=[0-9a-f]+)? -->$/ { f = 1 } END { print n + 0 }' AGENTS.md)
    total=$(wc -l < AGENTS.md | tr -d ' ')
    echo "baseline block: $block/80 lines, AGENTS.md: $total/200 lines"
    test "$block" -gt 0 || { echo "baseline block not found" >&2; exit 1; }
    test "$block" -le 80 && test "$total" -le 200

# Validate skills against the Agent Skills spec. Fails only on a non-zero
# exit: the warnings about .agents/skills and .claude/skills are expected,
# they hold this repo's own dogfood symlinks (see README).
[private]
lint-skills:
    gh skill publish --dry-run

# Test the sync script against throwaway repos
test:
    scripts/test-sync.sh

# Copy the committed baseline into another repo's working tree
sync target:
    scripts/sync.sh {{ quote(target) }}

# Run a skill eval (oasis-review, oasis-design-doc) in claude or codex
eval skill agent:
    tests/evals/run.sh {{ quote(skill) }} {{ quote(agent) }}
