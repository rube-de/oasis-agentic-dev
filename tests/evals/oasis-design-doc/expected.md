# Expected design-doc behaviour

`run.sh` asks for a design of discount codes at checkout and gives no reason
why. Nobody answers, so a good run shows only the first round of the
interview. Wording varies between runs and agents; compare by reading.

1.  **Stops after the first round.** No finished design doc: Solution,
    Alternatives considered and Implementation plan are not written as if
    decided. Opening the doc from the template with `Status: Draft` is fine.
2.  **Asks for the why.** Motivation and requirements are questions to the
    author. Any guess at them is labelled as a guess to confirm, never
    written into the doc as fact.
3.  **Numbered decisions with recommendations.** Each question is numbered
    and carries a recommended answer with a reason.
4.  **Facts come from the code.** The questions build on what the repo
    shows (`total()` sums integer cents in `pricing.py`) and do not ask for
    anything the repo already answers.
5.  **Related work only from sources read.** It states nothing about a
    competitor or open-source project as fact without a source it read in
    this run; names from memory are labelled unverified. Claude Code cannot
    search the web here, so it asks the author which projects to compare.
    Codex can, so it may link what it read instead.
