# DOCX Architecture: Root-Cause Fix Plan

Date: 2026-05-28
Status: CLOSED 2026-11-19. R1, R2, R4, R6, R7 implemented; R3 done upstream; R5, R9, R10 obsolete (verdicts below)
Goal: Eliminate `flatten_xml` hack and reconciler transforms. Make the pipeline produce correct output natively.

---

## Pipeline Trace: Where Each Difference Originates

```
Source XML → metanorma-iso Adapter → Uniword Builders → Package model
                                                          ↓
                                             Reconciler (repair/transform)
                                                          ↓
                                             Package#to_zip_content
                                                          ↓
                                             PackageSerialization (XML → string)
                                                          ↓
                                             ZIP packaging
```

Each remaining difference is introduced at a specific point. Fix it there, not later.

---

## Completed Fixes

### R1. Pretty-printed XML → Single-line XML (DONE)

**Root cause**: `moxml/config.rb` sets `@default_indent = 2`. Every `to_xml` call produces pretty-printed XML.

**Fix applied**: In `lutaml/xml/builder/base.rb:16`, set `context.config.default_indent = options.delete(:indent) || 0`. The Builder now produces flat XML by default.

**Files**: `lutaml-model/lib/lutaml/xml/builder/base.rb`

### R2. CRLF line ending after XML declaration (DONE)

**Root cause**: `flatten_xml` regex was a band-aid for moxml not supporting CRLF.

**Fix applied**:
1. Added `default_line_ending` config to `moxml/config.rb` with `LINE_ENDING_LF` and `LINE_ENDING_CRLF` constants
2. `Node#to_xml` applies line ending via `apply_line_ending` post-processing
3. `XmlSerializer#finalize_adapter_xml` adds line ending after declaration/doctype
4. Uniword passes `line_ending: "\r\n"` via `DOCX_XML_OPTIONS` constants

**Files**:
- `moxml/lib/moxml/config.rb` — `default_line_ending` attribute
- `moxml/lib/moxml/node.rb` — `apply_line_ending` method
- `lutaml-model/lib/lutaml/xml/builder/base.rb` — threads `line_ending` option
- `lutaml-model/lib/lutaml/xml/adapter/xml_serializer.rb` — `finalize_adapter_xml` uses `line_ending`
- `uniword/lib/uniword/docx/package_serialization.rb` — `DOCX_XML_OPTIONS` constants

**Result**: `flatten_xml` method ELIMINATED entirely.

### R4. Run merging in ParagraphBuilder (DONE)

**Root cause**: `ParagraphBuilder#<<` blindly appends runs without merging identical ones.

**Fix applied**: `ParagraphBuilder#<<` now routes through `append_run` which checks if the previous run has matching rPr and merges text if so.

**Files**: `uniword/lib/uniword/builder/paragraph_builder.rb`

### R6. Document statistics text collection (DONE)

**Root cause**: `collect_text` only walked body paragraphs, missing headers/footers/notes.

**Fix applied**: Split into `walk_paragraphs`, `walk_tables`, `walk_sdts`, `collect_notes`, `collect_headers_footers`. Uses `respond_to?` for duck-typing instead of type-checking.

**Files**: `uniword/lib/uniword/docx/document_statistics.rb`

### R7. Font signatures for East Asian fonts (DONE)

**Fix applied**: Added SimSun, SimHei, MS Mincho, MS Gothic to `font_metadata.yml` with correct signatures extracted from the ISO rice document.

**Files**: `uniword/config/font_metadata.yml`

---

## Remaining Items: Verdicts (2026-11-19)

Evidence: rice converted with `Metanorma::Iso::Processor.new.output(nil, "spec/examples/rice.presentation.xml", out, :docx)` on base 2e463195 with lutaml-model 0.8.175 and uniword 1.7.10; output unzipped and inspected.

| Item | Verdict | Evidence |
|---|---|---|
| R3 namespace ordering | DONE (upstream, lutaml-model) | `xml_serializer.rb:243` in lutaml-model 0.8.175 already does `hoisted_declarations.sort_by { prefix.nil? ? "" : prefix.to_s }`. Rice `word/document.xml` root declares xmlns in sorted order (aink, am3d, cx..cx8, m, mc, o, oel, r, v, w, w10, w14, w15, w16...). No code in metanorma-iso. |
| R5 sequential rIds | OBSOLETE (premise false, cosmetic) | The adapter strip (`clear_stale_template_content`) only removes `/image` and `/customXml` rels, not all non-infrastructure rels. The uniword reconciler does no rId renumbering (rIds come from the IdAllocator and are never reused). Rice `document.xml.rels` has ids 5-22 and 25-46: gaps are valid OPC. Every `r:id/r:embed/r:link` in document.xml resolves (no dangling). The proposed fix (drop the strip) would re-introduce stale template images and customXml, and renumbering would touch hyperlink ids (another lane). No change. |
| R9 bold redundancy | OBSOLETE | Word strips redundant `<w:b/>` on save; rice output has 0 `<w:b/><w:b/>`. Accepted difference. |
| R10 adjacent table merging | OBSOLETE (not reproduced) | Rice `document.xml` contains 0 occurrences of `</w:tbl><w:tbl>`. Reopen only with a reproducing input. |

## What Word Always Changes (ACCEPT)

1. **lastRenderedPageBreak** — Requires pagination engine
2. **Zoom percent** — Word recalculates
3. **rsid entries** — Word adds new rsids
4. **Timestamps** — `modified` always overwritten
5. **Page count** — Requires layout engine
