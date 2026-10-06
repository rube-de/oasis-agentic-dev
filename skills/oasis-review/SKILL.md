---
name: oasis-review
description: Review code against the org engineering standards. Self mode reviews your own diff before you open or update a PR and fixes Blocking findings; peer mode reviews someone else's PR by number and drafts comments. Stack-aware (gh stack).
license: Apache-2.0
---

# Oasis review

One pass, two modes, one severity vocabulary:

*   **Blocking**: must change before merge.
*   **Nit**: minor polish; the author may skip it.
*   **Optional**: a suggestion worth considering.
*   **FYI**: context for later, no action in this PR.

Every finding names `file:line` and says *why*, in terms of code health.

## Scope the diff

1.  Resolve the parent with the **Base** rule in `AGENTS.md`
    (`gh repo view --json defaultBranchRef` names the default branch).
2.  Diff with `git diff <parent>...HEAD` (peer mode: `gh pr diff <number>`).
3.  With `--stack`, repeat for every layer from the bottom up, each against
    its own parent, and report a design flaw on the lowest layer that
    introduced it.

Done when you know the exact diff for each layer under review.

## Self mode

1.  Read the intent: commits, the linked issue, and the design doc in
    `docs/design/` if the change has one.
2.  Size check per layer. Past about 400 changed lines or 15 files, propose
    a split as stack layers (`gh stack add`), refactors first.
3.  Read the main files first, then the rest, then the tests.
4.  Apply every item in [checklist.md](checklist.md), every rule in the
    repo's `AGENTS.md`, and conformance to the design doc.
5.  Report findings grouped by severity.
6.  Fix the Blocking findings, then run the review again.

Done when every changed line has been read, every checklist item applied,
and no Blocking finding remains.

## Peer mode

1.  Read the PR with `gh pr view <number>` and the diff. Read lower stack
    layers for context only; comment on this layer's diff.
2.  Broad view: if the change should not happen at all, stop and draft one
    courteous comment that says why and what to do instead.
3.  Review the main part's design first, then the rest of the files, using
    [checklist.md](checklist.md) and the repo's `AGENTS.md`.
4.  Draft comments about the code, never the author. Unlabelled means
    Blocking; label the rest Nit, Optional or FYI. Name what is good, too.
    A problem that lives in a lower layer points to that layer's PR.
5.  Hand the draft to the human, design verdict first.

Done when every changed file has been read and the draft leads with the
design verdict. The human decides what to post.
