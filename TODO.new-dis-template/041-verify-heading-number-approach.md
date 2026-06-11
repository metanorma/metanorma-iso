# TODO 041: Fix Heading Section Numbers — Reference Has Numbers in Text

## Status: DONE

## What

Our output strips section numbers from headings (e.g., "Scope" not "1Scope"). But the reference output KEEPS numbers in the text: "1Scope", "2Normative references", "4.1General...". The auto-numbering from the Heading styles would then DUPLICATE these numbers.

## Why

### Reference Output

```
Heading1: 1Scope
Heading1: 2Normative references
Heading2: 4.1General, organoleptic and health characteristics
```

### Our Output

```
Heading1: Scope
Heading1: Terms and definitions
Heading2: General, organoleptic and health characteristics
```

### Analysis

The reference output is from the OLD isodoc rendering pipeline which puts numbers in the text AND uses auto-numbering styles. This causes duplication (e.g., "1 1Scope").

Our approach of stripping numbers is CORRECT — the styles auto-generate the numbers. The reference output has duplicated numbers.

However, the reference Heading styles might NOT have `numPr` — they may not auto-number. Let me verify.

## Architecture

Check if the reference DOCX's Heading styles have `numPr`. If they do, our stripped approach is correct. If they don't, we need to include numbers in the text.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — heading title rendering

## Depends On

- None
