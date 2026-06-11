# Fix 1: Remove invalid `w:type="normal"` from footnotes/endnotes

## Status: DONE

## Changes
- `uniword/builder/footnote_builder.rb`: Removed `type: "normal"` from Footnote.new and Endnote.new
- `uniword/wordprocessingml/footnote.rb`: Added `render_nil: false` to type attribute mapping
- `uniword/wordprocessingml/endnote.rb`: Added `render_nil: false` to type attribute mapping
- `uniword/docx/reconciler.rb`: Added `VALID_NOTE_TYPES` constant and `strip_invalid_note_types` method

## Specs
- "strips invalid w:type from normal footnotes" — PASS
- "preserves valid separator types" — PASS
