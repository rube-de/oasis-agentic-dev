# Review checklist

Adapted from [What to look for in a code review][looking-for]. The standard:
approve once the change improves overall code health, even if it is not
perfect; never approve one that makes it worse.

[looking-for]: https://google.github.io/eng-practices/review/reviewer/looking-for.html

## Design

Do the pieces interact sensibly? Does the change belong in this codebase or
in a library? Does it fit the rest of the system, and is now the right time
for it?

## Functionality

Does it do what the author intended, and is that good for end users and for
the developers who will call it? Think through edge cases, error paths and
user-visible behaviour. Treat concurrency with suspicion: look for races and
deadlocks by reading, since running the code rarely shows them.

## Complexity

Can a reader understand each line, function and type quickly? Is anything
more generic than today's need, or built for a future that has not arrived?
That is over-engineering: ask for the simpler version.

## Tests

Does new or changed logic come with tests in the same change? Would each test
fail if the code broke? Are the assertions simple and meaningful, the cases
separated, the mocks limited to boundaries? Tests are code to maintain too.

## Naming

Does each name say fully what the thing is or does, without being hard to
read?

## Comments

Do comments explain *why* rather than *what*? Code that needs a *what* comment
usually needs to be simpler. Are old TODOs or warnings now obsolete?

## Style and consistency

Does the change follow the repo's configs and style guides, then the
surrounding code? Style-only preferences outside the guide are Nits.
Reformatting belongs in its own change.

## Documentation

If the change alters how people build, test, use or release the code, are
the README, docs and design doc updated in the same change? Deleted code
takes its docs with it.

## Every line

Read every human-written line, not just the shape of it. Generated code and
data files can be scanned. If you cannot understand a part, that is a finding.

## Context and code health

Look past the diff: does the surrounding function now need splitting? Does
the change leave the system healthier or add complexity that will compound?
Complexity it introduces is cleaned up now, not in a later PR.
