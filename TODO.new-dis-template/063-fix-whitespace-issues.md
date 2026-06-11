# 063: Fix Whitespace Issues Throughout Document

## Problem
The output has pervasive whitespace issues not present in the reference:
1. Extra double spaces in text content
2. Leading whitespace on paragraphs
3. Extra `<w:br>` elements where they shouldn't be
4. Trailing whitespace on paragraphs
5. SOURCE references have double spaces before clause numbers

## Evidence

### Double spaces in text:
```
Output:
  "[SOURCE: ISO 7301:2011,  3.1]"                    ← double space before "3.1"
  "[SOURCE: ISO 7301:2011,  3.2, modified..."         ← double space before "3.2"
  "<rice>  organic and inorganic..."                   ← double space after <rice>
  "Note 1 to entry: See       Figure C.1  ."          ← 7 spaces before "Figure"
  "Sampling shall be carried out in accordance with ISO 24333:2009,  Clause..."  ← double space
```

Reference (correct):
```
  "[SOURCE: ISO 7301:2011, 3.1]"                     ← single space
  "<rice> organic and inorganic..."                   ← single space
  "Note 1 to entry: See Figure C.1."                  ← single space
```

### Leading whitespace:
```
Output Para 128: "  time necessary for 90 %..."       ← 2 leading spaces
```

Reference Para 161: "time necessary for 90 %..."      ← no leading spaces

### Extra `<w:br>` elements:
The output has 23 paragraphs with `<w:br>` elements. The reference only has 13 (mostly in structural positions like annex headings and copyright block). Key problematic examples:
```
Output Para 51:  1 break in "ISO 712:2009, Cereals..."    ← reference has NO break here
Output Para 55:  1 break in "ISO 16634:—, Cereals..."     ← reference has NO break here
Output Para 85:  1 break in "Note 1 to entry..."          ← reference has NO break here
Output Para 120: 5 breaks in "Note 1 to entry: See..."    ← reference has 0 breaks here
Output Para 233: 1 break in "WARNING — Direct contact..." ← reference has NO break here
```

### Trailing whitespace:
```
Output Para 271: "puts \"Hello, world.\"%w{a b c}.each do |x| (1)  puts xend        "
                                                                                   ↑ trailing spaces
```

## Root Cause
1. Double spaces likely come from concatenation of inline elements where the XML parser adds spaces
2. Leading spaces in term definitions come from the XML source having leading whitespace
3. Extra `<w:br>` elements may be generated from line breaks in the XML that should be treated as spaces
4. SOURCE references: the comma-space-number pattern suggests the presentation XML has extra spaces

## Fix
1. Add text normalization when extracting text from XML nodes — collapse multiple spaces to one
2. Strip leading/trailing whitespace from paragraph text
3. Only emit `<w:br>` for explicit `<br/>` or line breaks in source, not from whitespace in XML
4. Specifically fix the SOURCE reference formatting to match "ISO XXXX:YYYY, N.N" pattern

## Priority
**HIGH** — Pervasive formatting issues visible in every section of the document.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — text extraction and paragraph rendering
- `lib/isodoc/iso/docx/inline.rb` — inline element rendering
