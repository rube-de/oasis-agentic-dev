# oasis-agentic-dev

Shared engineering baseline for Oasis repositories: the `AGENTS.md` rules, a
PR template and agent skills, written for humans and for Claude Code and
Codex alike.

## What is in this repo

*   `AGENTS.md`: the baseline between the `oasis-baseline` markers, followed
    by the rules for working on this repo.
*   `.github/pull_request_template.md`: the PR template every repo gets.
*   `skills/`: the skills, following the [Agent Skills](https://agentskills.io)
    format:
    *   `oasis-design-doc`: design doc before a non-trivial change.
    *   `oasis-review`: self-review before a PR, peer review of others' PRs.
    *   `oasis-pr-description`: PR title and body from the template.
*   `docs/design/`: design docs, starting with
    [the baseline's own design](docs/design/0001-agentic-baseline.md).

## Expected lint warnings

`just lint` runs `gh skill publish --dry-run` to validate the skills and fails
only when it exits non-zero. It always warns that `.agents/skills/` and
`.claude/skills/` contain installed skills: here they are committed symlinks
to `skills/`, so Claude Code and Codex load the skills in this repo too. The
tag-protection warning only matters for publishing with `gh skill`, which
this repo does not do.

## Status

In development. Piloted in `honoroll-io/honoroll`, then moved to the
`oasisprotocol` organization.

## Contact

Maintained by [rube-de](https://github.com/rube-de). Open an issue for
questions and proposals.
