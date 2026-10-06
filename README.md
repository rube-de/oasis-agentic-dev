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
*   `scripts/sync.sh`: copies all of the above into another repo.
*   `tests/review-fixture/`: a seeded diff for checking `oasis-review` in
    Claude Code and Codex.
*   `docs/design/`: design docs, starting with
    [the baseline's own design](docs/design/0001-agentic-baseline.md).

## Adopt the baseline in a repo

From a clean checkout of this repo and of the target repo:

```shell
just sync ../my-repo
```

The script writes the baseline block into `AGENTS.md`, creates `CLAUDE.md`,
copies the PR template and the skills, and stops on anything it would have to
overwrite by guesswork. Then, in the target repo:

1.  Fill in `## This repository`: overview, build and test commands, layout,
    repo-specific rules. Delete generic rules the baseline now covers.
2.  Keep `AGENTS.md` at most 200 lines.
3.  Review the diff and open a PR.

Run the same command again to update; the start marker records the source
commit.

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

## License

Copyright 2026 rube-de. Licensed under the [Apache License 2.0](LICENSE).
