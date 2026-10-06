---
name: oasis-design-doc
description: Write or refine a design doc in docs/design/ before implementing a change that meets the design-doc trigger in AGENTS.md (new component, public API or abstraction; persistent, on-chain, wire or config format change; security-sensitive; more than about 3 PRs; competing approaches).
license: Apache-2.0
---

# Oasis design doc

A design doc gets the design reviewed before code exists, then stays as the
record of the decision. The author owns the *why*; you find the facts, draw
out the decisions, and keep the doc short.

## Steps

1.  **Open the doc.** Continue an existing `docs/design/NNNN-slug.md`, or copy
    [template.md](template.md) to the next free number with `Status: Draft`.
2.  **Gather facts yourself.** Read the code, docs, issues and earlier design
    docs the change touches. Done when every claim the doc will rely on has a
    source you have read.
3.  **Grill the author** in rounds until the design is settled:
    *   Map the open decisions as a tree. Each round, ask every decision whose
        prerequisites are settled, numbered, each with your recommended
        answer and the reason. Wait for answers, then ask the next round.
    *   Ask only for decisions. Look facts up instead of asking for them.
    *   Take Motivation and Requirements from the author; draft them back in
        their substance, never invented.
    *   Stress-test with concrete edge-case scenarios, check the author's
        claims against the code and say so when they disagree, and replace
        fuzzy terms with precise ones.

    Done when no open decision remains and the author confirms the shared
    understanding.
4.  **Draft** every template section. Each Implementation plan step is one
    self-contained PR, a layer of a `gh stack`, with the tests it adds.
    Done when each section has content or says "n/a" with a reason.
5.  **Tighten.** Cut every sentence a reviewer does not need to say yes or
    no; follow the Google docguide. Done when the author agrees it is ready
    for review.

## Status

*   `Draft` while writing.
*   `Accepted` in the PR that proposes the doc; merging it is acceptance.
*   `Implemented` once the last plan step lands.
*   `Superseded by NNNN` when a later doc replaces the decision.
