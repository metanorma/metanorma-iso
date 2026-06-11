# TODO 001: xml:space="preserve" for newline content

## Status: DONE

## Problem
`Text.cast()`, `Run#create_text_object()`, and `InstrText#initialize()` only checked for leading/trailing spaces and tabs when deciding whether to set `xml:space="preserve"`. Newline characters (`\n`) in text content were not checked, causing 13+ `<w:t>` elements with newlines to be serialized without the required attribute. This violates the OOXML spec's whitespace handling rules.

## Files Changed
- `uniword/lib/uniword/wordprocessingml/text.rb:39` — added `|| content_str.include?("\n")`
- `uniword/lib/uniword/wordprocessingml/run.rb:248` — added `|| string.include?("\n")`
- `uniword/lib/uniword/wordprocessingml/instr_text.rb:25` — added `|| attrs[:text].include?("\n")`

## Verification
- All 122 uniword docx specs pass
- Generated DOCX has 0 `<w:t>` elements with whitespace but missing xml:space="preserve"

## Spec TODO
- Add unit spec for `Text.cast` covering newline content
- Add unit spec for `InstrText.new` covering newline content
