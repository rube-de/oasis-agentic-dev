# Expected review findings

`run.sh` builds a repo where `feature/discount` carries four known problems.
A self-mode review should report each of them; wording and severity labels
will vary between runs and agents, so compare by reading.

1.  **Over-engineering**: `DiscountStrategy`, `PercentageDiscount` and a
    factory with a registry serve one percentage discount. Blocking: a plain
    function does the job.
2.  **Test without an assertion**: `test_total_with_discount` calls the
    function and checks nothing, so it cannot fail when the code breaks.
    Blocking.
3.  **What-comment and duplicated logic**: the comment restates the loop, and
    the loop re-implements `total()`. Blocking or Nit; either way, flagged.
4.  **Size**: about 650 changed lines, almost all of them `regions.py`, which
    nothing uses. Propose dropping it or splitting it into its own stack
    layer with the code that uses it.
