# NNNN: Title

Status: Draft

One to three sentences: what is being decided, for whom.

## Motivation

The problem and why it matters now, from the user's or developer's side.

## Requirements

### Functional requirements

*   What must be observably true when the feature works, one checkable
    behaviour per bullet; each maps to a test in the Implementation plan.

### Non-functional requirements

Give each a target the author sets and, where it can be estimated, a
prediction with its basis (benchmark, measurement or stated assumption).
"n/a" with a reason for any that does not apply.

*   **Latency and throughput**: per operation, e.g. p95.
*   **Privacy**: what data is visible to whom: public on-chain, confidential
    in a TEE, the operator, third parties.
*   **Infrastructure**: the minimum needed to run it (services, nodes,
    hardware, cost).
*   **Scaling**: expected load at launch and at 10x; what breaks first.
*   **Security, compatibility, operability** where they apply.

## Related work

*   **[Project](link)**: how this competitor or production-grade open-source
    solution handles the problem and what we take from it; why we do not
    adopt it whole goes under Alternatives considered. "n/a" with a reason
    when nothing comparable exists.

## Challenges

The constraints and unknowns that make this hard.

## Solution

The design, with only the detail a reviewer needs to judge it. Interfaces,
data formats and failure modes over implementation detail.

## Alternatives considered

*   **Alternative**: a design we weighed, including adopting a project from
    Related work, and why it lost.

## Implementation plan

Each step is one self-contained PR, a layer of a `gh stack`:

1.  What the PR does, and the tests it adds.
