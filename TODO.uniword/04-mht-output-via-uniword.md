# 04: MHT Output via Uniword

## Summary

Evaluate and potentially replace html2doc's MHT packaging with Uniword's `MhtmlPackage`. If viable, metanorma-iso can use Uniword for both DOCX and MHT output.

## Motivation

Uniword already has an MHTML module (`Uniword::Mhtml`) with:
- `MhtmlPackage.from_file` / `MhtmlPackage.to_file`
- `Document` model with `html_parts`, `image_parts`, `header_footer_parts`
- `StylesConfiguration`, `NumberingConfiguration`, `Theme`
- `MathConverter` (HTML MathML → Word MathML)

This could replace html2doc's `mime.rb` (MIME packaging) entirely. But html2doc's MHT path includes significant HTML-to-Word-XML conversion logic that Uniword's MHTML module may not replicate.

## Analysis

### What html2doc does for MHT (that Uniword MHTML may not)

1. **HTML → Word XML conversion**: `process_html` converts HTML to Word-compatible XML with `mso-*` styles, VML, etc.
2. **Image handling**: Renames images to UUIDs, detects MIME types, resizes via vectory
3. **Math conversion**: MathML → OMML via Plurimath, with post-processing (unitalic, accents, plane1 fonts)
4. **List handling**: HTML `<ul>`/`<ol>` → `MsoListParagraphCxSp*` with numbering
5. **Footnote/endnote handling**: HTML footnotes → Word footnote XML
6. **MIME packaging**: Assembles all parts into a multipart MIME document

### What Uniword MHTML currently does

1. Parses existing MHTML files into a `Document` model
2. Extracts HTML, CSS, images, headers/footers
3. Re-serializes to MHTML format
4. Provides `StylesConfiguration`, `NumberingConfiguration`, `Theme` models

### Gap analysis

| Feature | html2doc | Uniword MHTML | Gap? |
|---|---|---|---|
| HTML → Word XML | Yes | No (reads only) | **Yes — major** |
| Image UUID + MIME | Yes | Partial | **Yes** |
| Math ML → OMML | Yes | Has MathConverter | Small |
| List numbering | Yes | No | **Yes** |
| Footnotes | Yes | No | **Yes** |
| MIME packaging | Yes | Yes | No |
| Round-trip fidelity | Good | Unknown | Needs testing |

## Recommendation

**Phase 1 (now):** Keep html2doc for MHT output. It's stable and handles all the edge cases.

**Phase 2 (later):** If Uniword's MHTML module gains HTML→Word XML conversion, evaluate migration. This would require:
- Uniword MHTML to accept Word-formatted HTML and produce valid MHT
- All html2doc HTML processing to move into Uniword or isodoc
- Comprehensive round-trip testing against existing MHT output

## Tasks (Phase 1 only)

### 1. Keep html2doc as MHT dependency

No changes needed. The existing `isodoc → html2doc → MHT` pipeline works.

### 2. Document the decision

Add a comment in isodoc's `postprocess.rb`:
```ruby
# MHT output: via html2doc (HTML → MIME packaging)
# DOCX output: via Uniword (XML → OOXML directly)
```

## Acceptance Criteria

- [ ] MHT output unchanged and working
- [ ] Decision documented in isodoc codebase
- [ ] No regression in existing MHT tests

## Open Questions

- Should we invest in Uniword MHTML's write path, or is html2doc's MHT path good enough?
- What percentage of metanorma-iso users actually use MHT vs DOCX?
