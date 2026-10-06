# oasis-agentic-dev

Source of the Oasis agentic engineering baseline.

<!-- oasis-baseline:start -->

These rules apply to humans and agents alike.

## Engineering standards

*   Solve today's problem; add generality when a second real use arrives.
*   Write code a reader understands quickly; simple beats clever.
*   Pass dependencies and config explicitly; keep state local.
*   Comments explain *why*: would it make sense in six months to someone
    reading only the current code? Change history belongs in the PR.
*   Names say fully what a thing is or does.
*   Logic changes ship with tests in the same PR. Each test fails for the
    right reason when the code breaks. Favour a few behavioural tests on
    business rules, edge cases and boundaries; unit first, end-to-end for
    critical paths; mock only at boundaries; skip coverage-only tests. Bug
    fixes start with a failing regression test.
*   Follow repo configs and style guides, then the surrounding code.
*   Clean up complexity you introduce before merge; file an issue for
    existing mess you expose.

## Workflow

*   **Design doc** first when a change adds a component, public API or
    abstraction; changes a persistent, on-chain, wire or config format; is
    security-sensitive; spans more than about 3 PRs; or has competing
    approaches. Use `oasis-design-doc` and merge the doc before coding.
*   **Small PRs**: one complete, self-contained change, about 100 lines;
    split past about 400 lines or 15 files. Refactors get their own PR.
    Multi-PR work is a stack (`gh stack`); every layer stays green.
*   **Commits**: atomic, each builds and passes tests, no do-then-undo
    churn; `git mv` for renames.
*   **Base**: a PR's parent is the nearest unmerged branch below it in
    `gh stack view --json` (`branches` runs bottom to top; `base` is a SHA),
    else its PR base branch, else the repo's default branch. Diff with
    `git diff <parent>...HEAD`.
*   **Self-review** before requesting review: run the repo checks, run
    `oasis-review` in self mode, fix every Blocking finding. You own the
    code your agent wrote; reviewer time is precious.
*   **PR description**: `oasis-pr-description` fills
    `.github/pull_request_template.md`. Lead with why.
*   **Feedback**: when a reviewer is confused, clarify the code itself.

## Documentation

*   Update docs in the same PR as the code; delete dead docs; prefer brief
    to exhaustive; link instead of duplicating.
*   Markdown follows the Google docguide: one H1, ATX headings, fenced code
    with a language, descriptive link text, lists over tables, 80 columns.
*   Design docs live in `docs/design/NNNN-slug.md` with a `Status` line and
    stay as the record of the decision once implemented.

## Safety

*   Keep secrets out of git and output; refer to them by name or path.
*   Force-push only your own branches, with `--force-with-lease`.
*   Confirm before destructive or outward-facing actions.
*   `CLAUDE.md` only imports `AGENTS.md`; rules live here.

## Skills

*   `oasis-design-doc`: when the design-doc trigger applies.
*   `oasis-review`: self mode before every PR; peer mode for others' PRs.
*   `oasis-pr-description`: PR title and body, on open and on every push.

<!-- oasis-baseline:end -->

## This repository

This repo is the source of the baseline above, the PR template and the
`oasis-*` skills. Rationale: `docs/design/0001-agentic-baseline.md`.

*   The block between the markers in this file is the canonical baseline.
    Keep it at most 80 lines and this file at most 200.
*   `.github/pull_request_template.md` is the canonical PR template.
*   Skills live in `skills/<name>/` with portable frontmatter only (`name`,
    `description`). Each has committed symlinks at `.agents/skills/<name>`
    (Codex) and `.claude/skills/<name>` (Claude Code).
*   Run `just lint` before every PR.
