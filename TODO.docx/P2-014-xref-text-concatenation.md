# 020 — Fix cross-reference text concatenation

## Status: KNOWN BUG (also in REF)

Cross-references concatenate with adjacent text: `"3.1husked rice"`,
`"Note13.5,Note1"`, `").B.3.2B.3.1"`.

This is a presentation XML issue — the formatted text includes both the
xref label and adjacent content in the same element. The inline renderer
faithfully renders the content as-is.

Both the old pipeline (REF) and our adapter have this behavior. Fix would
require changes to the presentation XML generation, not the DOCX adapter.
