# TODO 003: Add specs for xml:space="preserve" behavior

## Status: DONE

## Problem
No dedicated unit tests for the `Text.cast()` newline handling fix, the `InstrText` newline handling, or the `Hyperlink#to_model` Text.cast path.

## Files Created
- `uniword/spec/uniword/wordprocessingml/text_spec.rb` — 10 examples covering:
  - Leading/trailing space, tab, newline → xml_space="preserve"
  - Plain text → no xml_space
  - Identity (same object) for Text input
  - nil → nil
  - XML serialization includes attribute
- `uniword/spec/uniword/wordprocessingml/instr_text_spec.rb` — 3 examples
- `uniword/spec/uniword/hyperlink_spec.rb` — 3 examples

## Verification
- All 16 new specs pass
