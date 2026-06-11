# TODO 006: Centralize xml:space detection in Text model

## Status: DONE

## Problem
The whitespace-detection logic was duplicated in 3 places:
- `text.rb:39` — `Text.cast()`
- `run.rb:248` — `Run#create_text_object()`
- `instr_text.rb:25` — `InstrText#initialize()`

## Fix
Extracted `Text.preserve_whitespace?(content)` class method. All 3 call sites now delegate to it.

## Files Changed
- `uniword/lib/uniword/wordprocessingml/text.rb` — added `preserve_whitespace?` class method
- `uniword/lib/uniword/wordprocessingml/run.rb` — uses `Text.preserve_whitespace?`
- `uniword/lib/uniword/wordprocessingml/instr_text.rb` — uses `Text.preserve_whitespace?`
- `uniword/spec/uniword/wordprocessingml/text_spec.rb` — 6 new examples for `preserve_whitespace?`

## Verification
- 144 specs (new + docx) pass with 0 failures
