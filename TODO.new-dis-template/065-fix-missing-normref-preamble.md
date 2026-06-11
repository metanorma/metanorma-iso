# 065: Fix Missing Normative Reference Preamble Text

## Problem
The output is missing the "For the purposes of this document, the following terms and definitions apply" preamble text and the "ISO and IEC maintain terminology databases" text in the Terms section. These appear in the reference but are absent from the output.

## Evidence
```
Reference Terms section (paras 86-94):
  86: "3Terms and definitions"
  87: "For the purposes of this document, the following terms and definitions apply."
  88: "ISO and IEC maintain terminology databases for use in standardization..."
  89: "ISO Online browsing platform: available at https://www.iso.org/obp"
  90: "IEC Electropedia: available at https://www.electropedia.org"
  91: "For the purposes of this document, the following terms and definitions apply."
  92: "ISO and IEC maintain terminological databases..."
  93: "ISO Online browsing platform: available at http://www.iso.org/obp"
  94: "IEC Electropedia: available at http://www.electropedia.org"
  95: "3.1"

Output Terms section (paras 58-63):
  58: "3Terms and definitions"
  59: "ISO Online browsing platform: available at https://www.iso.org/obp"
  60: "IEC Electropedia: available at https://www.electropedia.org"
  61: "ISO Online browsing platform: available at http://www.iso.org/obp"
  62: "IEC Electropedia: available at http://www.electropedia.org"
  63: "3.1"
```

Missing from output:
1. "For the purposes of this document..." (appears twice in reference)
2. "ISO and IEC maintain terminology databases..." (appears twice)

## Fix
Ensure the preamble paragraphs are rendered before the first term entry. These come from the presentation XML `<terms>` section and should be included in the output.

## Priority
**MEDIUM** — Content is present but preamble text adds important context.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — terms section rendering
