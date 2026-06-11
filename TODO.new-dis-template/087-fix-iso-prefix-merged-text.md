# 087: "ISO" prefix merged into annex E body text

## Problem
In Annex E, the output merges "ISO" into the body text: "ISOThis International Standard gives the minimum specifications..." when it should be a separate element (possibly a hyperlink or eref reference to ISO).

## Reference:
The reference has "ISO" as a separate run (possibly with an rStyle like `stdpublisher0`), followed by the text.

## Output:
"ISOThis International Standard gives..." — "ISO" is concatenated without a space.

## Root cause
The inline renderer renders an `eref` or `semx` element that contains just "ISO" but the text gets concatenated with the following text node without a space separator.

## Fix
Ensure text nodes have proper spacing. This is related to the whitespace normalization in `add_text` — the space between elements should be preserved.

## Location
- `lib/isodoc/iso/docx/inline.rb` — `add_text`, `render_ordered_inline`
