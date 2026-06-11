# 086: Missing `)` footnote markers and `NOTELower` prefix on notes

## Problem
Several note-related issues:

### 1. Note text formatting
Reference: `Note 1 to entry: See Figure C.1.`
Output: `Note 1 to entry: See Figure C.1 .` (extra space before period)

### 2. Missing "NOTE" prefix
Reference has `NOTELower mass fractions of moisture...` (a single paragraph with "NOTE" as label prefix).
Output has the note text but may be missing the "NOTE" label.

### 3. Footnote `)` markers
Multiple normref entries missing the `)` footnote marker. See 078.

## Fix
1. Fix whitespace in note rendering (extra space before period)
2. Ensure "NOTE" label is properly prepended to note text
3. See 078 for footnote markers

## Location
- `lib/isodoc/iso/docx/inline.rb` — `add_text` whitespace normalization
- `lib/isodoc/iso/docx/adapter.rb` — `visit_note`
