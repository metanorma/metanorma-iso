---
title: 108-018 - Fix note/example count mismatch
priority: P2
status: partial
---

# 108-018: Fix Note/Example Count Mismatch

## Problem

The historical reference is `spec/examples/rice.docx`. The counts below
match the exact paragraph style IDs in its `word/document.xml`.

The current DOCX conversion of `spec/examples/rice.presentation.xml`
produces 5 `Note`, 6 `Noteindent`, 1 `Figurenote`, 2 `Example`,
1 `Exampleindent`, and 17 `Definition` paragraphs. The DIS fixture
produces 5 `Note`, 4 `Noteindent`, 1 `Figurenote`, 2 `Example`,
1 `Exampleindent`, and 15 `Definition` paragraphs.

The reference counts its table footnotes as `Note` and its code callout
label and annotation as `Example`. Its definition text and paragraph
boundaries also differ from the current presentation XML. The remaining
work is to verify those differences against matching input and output
before treating the legacy style totals as renderer acceptance counts.

### Notes:
- Latest: 6 paragraphs with `Note` style
- Reference: 15 paragraphs with `Note` style

### Examples:
- Latest: 2 paragraphs with `Example` style
- Reference: 4 paragraphs with `Example` style

### Definition:
- Latest: 15 paragraphs with `Definition` style
- Reference: 16 paragraphs with `Definition` style

## Possible Causes

1. **Note rendering**: The adapter renders notes via `visit_note`, but some notes may be:
   - Inside terms (termnote) — rendered via `render_term_notes`
   - Inside tables — not being rendered
   - Inside examples — nested notes
   - General notes in clause text

2. **Example rendering**: Some examples may have a `name` (fmt_name) that gets its own paragraph with Example style, plus the example body. The count suggests some examples are missing.

3. **Definition**: One definition paragraph is missing. Could be a term definition that's not being rendered.

## Investigation Needed

1. Count all `<note>` elements in the presentation XML
2. Count all `<example>` elements in the presentation XML
3. Trace which ones are rendered vs skipped in the adapter
4. Check if table notes and example notes are being rendered

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — visit_note, visit_example, render_term_notes
- `lib/isodoc/iso/docx/inline.rb` — note/example rendering
