---
title: 108-018 - Fix note/example count mismatch
priority: P2
status: done
---

# 108-018: Fix Note/Example Count Mismatch

Reference source: `spec/fixtures/iso/is/document-en.dis.presentation.xml`.

- 9 notes with `Note` or `Noteindent`: one clause note, three table notes,
  and five term notes. The three table notes render inside table cells.
- 1 figure note with `Figurenote`.
- 2 examples with `Example` or `Exampleindent`: one term example and the
  annex example titled “Sample Code”.
- 15 definitions with `Definition`, all inside terms.

`spec/isodoc/docx/dis_note_example_spec.rb` matches each source element
to a separate styled paragraph using text from its first paragraph
or the Sample Code label. Bibliography status notes, footnotes, code
callouts, and definition lists are outside these counts.

The historical `spec/examples/rice.docx` includes table footnotes and
code callouts in its style totals and has different definition content.
