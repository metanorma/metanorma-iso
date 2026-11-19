# 020 — Fix cross-reference text concatenation

## Status: NOT REPRODUCIBLE in the DOCX adapter output (2026-11-19)

The card reported cross-references concatenating with adjacent text:
`"3.1husked rice"`, `"Note13.5,Note1"`, `").B.3.2B.3.1"`.

Measured on the rice sample (`spec/examples/rice.presentation.xml`) through
the adapter: no hyperlink edge touches alphanumeric text without the source
spacing, and the strings come from joining separate paragraphs (TermNum
`3.1` and Terms `paddy` are different `w:p`) or table cells in a flat text
dump, not from xref runs. `(B.3.2) ... (B.3.1)` renders with its spaces and
punctuation intact. No code change needed; behaviour is pinned by
`spec/isodoc/docx/xref_spacing_spec.rb`.

Side observation (not a pipeline case): a bare `<fmt-xref>` directly under
`<p>`, without the `<semx element="xref">` wrapper that presentation XML
always emits, renders no text at all.
