# 083: Bibliography entries formatting differences

## Problem
Bibliography entries have minor text differences from the reference.

## Specific differences:
1. Missing `)` footnote markers (see 078)
2. Reference normref style is `normref`, output uses `RefNorm`
3. Reference biblio style is `BiblioEntry`, output also uses `BiblioEntry` (matches)
4. Some entries have "ISO" prefix merged differently: output "ISOThis International Standard..." vs reference has it separated

## Example:
- Reference: `[1]ISO 2146:1988) , Documentation — Directories...`
- Output: `[1]ISO 2146:1988, Documentation — Directories...`

## Fix
1. Fix footnote markers (see 078)
2. Ensure `RefNorm` style maps to correct template style
3. Check text concatenation in bib entry rendering

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `visit_bibliographic_item`, `render_bib_item_content`
