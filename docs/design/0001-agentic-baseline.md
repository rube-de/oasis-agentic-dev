# 0001: Agentic engineering baseline

Status: Accepted

An org-wide `AGENTS.md` baseline and three shared skills that turn the
proposal *Standardizing Agentic Development and Engineering Practices*,
[Google's eng-practices] and [Google's docguide] into instructions every coding
agent follows in every repo.

[Google's eng-practices]: https://google.github.io/eng-practices/
[Google's docguide]: https://google.github.io/styleguide/docguide/

## Motivation

Agents make code and prose cheap, which moves the cost to review and to
long-term maintenance. Without shared rules every repo and every developer
prompts differently, and the familiar failures scale up: big PRs, speculative
abstractions, what-comments, superficial tests, PR bodies without a why, and
reviewers cleaning up AI output the author never read. The proposal asks for a
shared baseline that keeps the engineering bar high, design review before
implementation, and author self-review before anyone else's time is spent.

## Requirements

### Functional requirements

*   One baseline that every repo inherits, readable by humans as contributing
    guidelines and loaded automatically by agents.
*   Works in Claude Code and Codex.
*   Skills for the three moments the proposal names: design before code,
    self-review before review, and a PR description that carries the why.
*   Stacked PRs (`gh stack`) are first-class: review and describe one layer at
    a time.
*   Repo-specific rules stay with the repo; language style stays in each
    repo's `CONTRIBUTING.md`.

### Non-functional requirements

*   Concise: baseline block at most 80 lines, whole `AGENTS.md` at most 200.
*   One source of truth per rule; no copies that drift.
*   Committed with the code, so cloud and CI agents see the same rules.
*   No dependency on personal plugins or tools beyond `git`, `gh` and a POSIX
    shell.

## Challenges

*   **Codex has no include syntax.** It concatenates `AGENTS.md` files from the
    repo root down to the working directory, so a baseline in a referenced
    file is only a request the model may skip.
*   **Claude Code skips `AGENTS.md` when a `CLAUDE.md` exists**, and older
    versions do not read `AGENTS.md` at all.
*   **The tools look for skills in different places.** Codex reads
    `.agents/skills/`; Claude Code reads only `.claude/skills/<name>`, where
    each entry may be a symlink.
*   **Instruction files lose adherence as they grow.** Anthropic targets under
    200 lines; Codex stops at 32 KiB by default.

## Solution

### Baseline block

The baseline is a block of Markdown inside each repo's `AGENTS.md`:

```markdown
<!-- oasis-baseline:start v=<source commit> -->
...engineering standards, workflow, documentation, safety, skills...
<!-- oasis-baseline:end -->

## This repository
```

Everything outside the markers belongs to the repo. `CLAUDE.md` contains only
`@AGENTS.md`, so every Claude Code version loads the same file Codex does. The
canonical block is the one in this repo's own `AGENTS.md`; there is no second
copy.

The rules come from three places: the proposal, Google's eng-practices and
docguide, and the proven generic rules of `honoroll-io/honoroll`'s
`AGENTS.md`. Each rule is a positive, imperative line that carries its reason.

### Skills

*   **`oasis-design-doc`** interviews the author in rounds (open decisions
    first, a recommended answer for each, facts looked up rather than asked),
    then drafts Motivation, Requirements, Challenges, Solution, Alternatives
    considered and an Implementation plan whose steps are stack layers.
*   **`oasis-review`** applies Google's *What to look for* checklist, the
    repo's `AGENTS.md` and the design doc. Self mode runs before your own PR
    and fixes Blocking findings; peer mode drafts comments on someone else's
    PR and leaves posting to the human.
*   **`oasis-pr-description`** fills the synced PR template: an imperative
    title, Why, What with the smallest useful visual, Evidence, and Risk as a
    one-way or two-way door with its blast radius.

All three are model-invoked so the workflow rules in `AGENTS.md` reach them,
and all three resolve a PR's base the same way: the nearest unmerged branch
below it in the stack, else the PR's base branch, else the default branch.

### Distribution

`just sync <checkout>` copies the block, the PR template, the skills and the
`CLAUDE.md` shim into a consumer repo's working tree and stamps the source
commit into the start marker. The human reviews the diff and opens the PR.
Skills land in `.agents/skills/<name>/` with `.claude/skills/<name>` symlinks
next to them. A second run produces no diff.

## Alternatives considered

*   **Baseline in a separate file referenced from `AGENTS.md`.** Cleaner to
    sync, and Claude Code would expand an `@` import, but Codex would only see
    a request to read the file.
*   **Claude Code or Codex plugin marketplaces.** Auto-updating, but they
    carry skills only, install per user, namespace skill names, and miss
    cloud and CI agents.
*   **`npx skills` or `gh skill install`.** Both produce the right skills
    layout, but neither delivers `AGENTS.md` or the PR template, and a second
    channel means two update paths. The repo stays installable by both for
    individuals.
*   **Per-developer global instructions.** Nothing committed, so cloud agents
    and teammates without the setup get nothing.
*   **Git submodule.** Fresh clones miss it, and symlinks across submodules
    are fragile.
*   **Reusing matt-pocock's `pr` and `code-review` skills.** Good ideas, now
    adapted, but they depend on a personal setup step and a glossary.

## Implementation plan

Bootstrapping an empty repo gains nothing from many PRs, so the init work is
one PR with logical commits:

1.  This design doc.
1.  Skeleton, `AGENTS.md` with the baseline block, PR template, lint.
1.  `oasis-review` with its checklist and a seeded review fixture.
1.  `oasis-pr-description`.
1.  `oasis-design-doc`.
1.  `scripts/sync.sh` with tests.

Then a pilot in `honoroll-io/honoroll`: one PR that syncs the baseline and
trims its 221-line `AGENTS.md` to at most 200 lines by deleting the generic
rules the baseline now carries. Success means both agents load the skills and
the next three to five PRs there go through self-review and
`oasis-pr-description`. After the pilot the repo moves to `oasisprotocol`.

Out of scope, tracked in one follow-up issue: pull-based sync automation, CI
evidence for self-review, agent PR review in CI, auto-implementation of
low-risk issues, security review as a first-class step, and vendoring
`github/gh-stack` once it reaches 1.0. Provider choice, budget and billing are
org decisions outside this repo.

## See also

*   [AGENTS.md](https://agents.md)
*   [Codex AGENTS.md discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
*   [Claude Code memory and AGENTS.md](https://code.claude.com/docs/en/memory)
*   [Claude Code skills](https://code.claude.com/docs/en/skills)
*   [gh-stack](https://github.com/github/gh-stack)
