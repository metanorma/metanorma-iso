---
title: 108-018 - Fix note/example count mismatch
priority: P2
status: partial
---

# 108-018: Fix Note/Example Count Mismatch

## Measured paragraph styles

| Artifact | Note | Noteindent | Figurenote | Example | Exampleindent | Definition |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Historical reference (`spec/examples/rice.docx`) | 15 | 0 | 0 | 4 | 0 | 16 |
| Current render of `spec/examples/rice.presentation.xml` | 5 | 6 | 1 | 2 | 1 | 17 |
| Current render of `spec/fixtures/iso/is/document-en.dis.presentation.xml` | 5 | 4 | 1 | 2 | 1 | 15 |

Counts use exact paragraph style IDs in `word/document.xml`. The historical
reference counts table footnotes as `Note` and the source code callout
label and annotation as `Example`. Its definition text and paragraph
boundaries differ from the current presentation XML.

The DIS fixture contains five content notes, five term notes, one
block example, one term example, and 15 term definitions. Its note
paragraphs use `Note`, `Noteindent`, and `Figurenote`. The source code
annotation is present in the generated DOCX.

## Remaining work

Agree on a reference generated from the same DIS source, or define the
expected paragraph roles for this fixture, before asserting count parity.
