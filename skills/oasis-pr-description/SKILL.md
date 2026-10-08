---
name: oasis-pr-description
description: Write or update a pull request title and body from the repo's PR template. Use when opening a PR, after pushing new commits to one, or before merge to confirm the body still matches the change. Stack-aware (gh stack).
license: Apache-2.0
---

# Oasis PR description

A PR description is the permanent record of *why* a change exists. Fill the
repo's `.github/pull_request_template.md`; if it is missing, stop and say the
repo needs the baseline synced from `oasis-agentic-dev`.

## Steps

1.  Collect the material: the parent per the **Base** rule in `AGENTS.md`,
    `git diff <parent>...HEAD`, the commits, the linked issue or design doc,
    and test or command output.
2.  **Title**: one imperative, standalone sentence of what the PR does
    ("Remove size limit on RPC freelist"), in the repo's commit convention.
3.  **Why**: the problem, the context and the decisions the code cannot
    show. Link the issue or design doc and summarize it, since links rot.
4.  **What**: a short summary of the change. Add the smallest visual that
    makes the point; [visuals.md](visuals.md) lists the options.
5.  **Evidence**: before and after, as test output, command output or a
    screenshot for UI changes.
6.  **Risk**: a one-way door (hard to reverse: migrations, on-chain or wire
    formats, deletions) or a two-way door; the blast radius (who or what
    breaks if it is wrong); known shortcomings and follow-ups.
7.  **Stack layer**: say what this layer adds and why it is a separate step.
    GitHub's stack view links the layers, so leave the list of PRs out.
8.  **Checklist**: tick the self-review box only if `oasis-review` ran in
    self mode in this session on the current HEAD with no Blocking finding.
    Otherwise run it now, or leave the box unticked and say why. Tick the
    other boxes only when true.
9.  Remove every section that does not apply; a typo fix has no blast
    radius. Show the result to the human, then write it with
    `gh pr edit <number> --title <title> --body-file <file>` (or
    `gh pr create`) once they confirm.

Done when every remaining section holds concrete content, the Why says
something the diff does not, and the title stands alone in `git log`.
