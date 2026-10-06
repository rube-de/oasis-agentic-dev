set shell := ["sh", "-eu", "-c"]

# List recipes
default:
    @just --list

# Lint Markdown and check the AGENTS.md line budgets
lint: lint-markdown lint-budgets

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
