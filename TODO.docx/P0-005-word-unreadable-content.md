# 088: DOCX "won't open" — root cause investigation

## Symptom
User reports `rice-dis-output-latest.docx` won't open in Word.

## Validation performed
- ZIP structure: Valid, 27 entries
- document.xml: Valid XML, no parse errors
- Content_Types: All overrides match existing files
- Styles: All 39 pStyles + 12 rStyles are defined in styles.xml
- Numbering: All numId references are defined
- Footnotes: All footnote IDs 1-8 are defined and have content
- Hyperlinks: 69 with anchor (valid), 6 with r:id (all in rels)
- Section properties: 3 sectPr, matching reference pattern
- Relationship IDs: All rIds in document.xml.rels point to existing files

## Potential causes
1. **Custom XML parts** — `docProps/custom.xml` exists in output but not in reference. Word may reject custom properties with unexpected attributes.
2. **Template-derived infrastructure** — Settings, styles, etc. are copied from the DIS template. If the template has features incompatible with the user's Word version, this could cause issues.
3. **Image CID references** — The output has inline images that may reference temporary files.
4. **Encoding issues** — Check if any text contains characters that Word can't handle.

## Immediate fix to try
1. Remove `docProps/custom.xml` and its content type override
2. Test opening after each removal to isolate the cause

## Status: DONE (verified in Microsoft Word, 2026-11-19)

## Verification (2026-11-19)
- rice.presentation.xml rendered to DOCX at ac2393fb (lane/1728-cards-batch4), opened in Microsoft Word read-only: no "unreadable content" or repair dialog.
- Table of contents entries clicked in Word jump to their headings.
