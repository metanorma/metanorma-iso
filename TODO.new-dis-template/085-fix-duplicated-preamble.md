# 085: Duplicated content — "For the purposes" preamble appears twice

## Problem
The output has the terms preamble text appearing twice:
1. Once in the first terms section (Clause 3)
2. Again in a second terms section

## Output:
```
60: "For the purposes of this document, the following terms and definitions apply."
61: "ISO and IEC maintain terminology databases..."
62-63: ISO/IEC URLs
64: "For the purposes of this document, the following terms and definitions apply."  ← DUPLICATE
65: "ISO and IEC maintain terminological databases..."
66-67: URLs again
```

## Reference:
Only has the preamble ONCE. The presentation XML contains two copies because there are two `<terms>` sections (one for the main terms and one for a sub-section), but the reference only renders the preamble for the first one.

## Root cause
The presentation XML has duplicate preamble paragraphs in both the outer `<terms>` and an inner nested section. The adapter walks both, producing duplicate output.

## Fix
Either:
1. Detect and skip the second preamble paragraph (check if text starts with "For the purposes")
2. Check if the preamble is a duplicate of one already rendered
3. Only render preamble from the outermost terms section

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `visit_terms_section`, `walk_mixed_content`
