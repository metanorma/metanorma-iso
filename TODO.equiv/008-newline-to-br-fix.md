# TODO 008: Fix LF in <w:t> causing Word "unreadable content"

## Status: DONE

## Problem
Generated DOCX had 20 `<w:t>` elements containing literal `\n` (LF, 0x000A)
characters. OOXML expects line breaks to be represented as `<w:br/>` elements,
not raw newlines in text content. Word's repair step removed all such newlines.

## Root Cause
`ParagraphBuilder#<<` created a single `Run.new(text: string)` when appending
strings, passing any embedded `\n` directly into `<w:t>`. While `Text.cast`
correctly sets `xml:space="preserve"`, the OOXML spec forbids LF in CT_Text
content regardless. Line breaks must use `<w:br/>` elements.

## Fix
Added `append_string` private method to `ParagraphBuilder` that:
- Passes plain strings (no newlines) through unchanged
- Splits strings containing `\n` at newline boundaries
- Creates separate text runs for each segment
- Inserts `<w:br/>` runs between segments

**File:** `uniword/lib/uniword/builder/paragraph_builder.rb`

## Verification
- 5 new specs in `paragraph_builder_spec.rb` (split, consecutive, leading, trailing)
- All 26 paragraph builder specs pass
- All 137 docx specs pass
- rice_fixed11.docx: 0 text elements with newlines (was 20)
- rice_fixed11.docx: 48 `<w:br/>` elements (was 24)
