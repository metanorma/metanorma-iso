# DOCX Architecture: Root-Cause Fix Plan

Date: 2026-05-28
Status: Root-cause fixes implemented for R1, R2, R4, R6, R7
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

## Remaining Fixes

### R3. Namespace declaration ordering

**Origin**: `lutaml/xml/adapter/xml_serializer.rb:215-226` builds `attributes` hash from `element_node.hoisted_declarations`. Hash uses insertion order.

**Root-cause fix**: Sort `hoisted_declarations` by prefix:
```ruby
element_node.hoisted_declarations.sort_by { |prefix, _|
  prefix.nil? ? "" : prefix.to_s
}.each do |key, uri|
```

**Files**: `lutaml-model/lib/lutaml/xml/adapter/xml_serializer.rb:215`

### R5. Sequential rIds

**Origin**: `adapter.rb clear_stale_template_content` strips non-infrastructure relationships, leaving gaps. Reconciler renumbers them.

**Root-cause fix**: Remove adapter-level strip. Let reconciler handle entirely.

**Files**: `metanorma-iso/lib/isodoc/iso/docx/adapter.rb`

### R9. Bold element redundancy

**Low priority** — Word strips redundant `<w:b/>` during save.

### R10. Adjacent table merging

**Medium priority** — requires body-level post-processing.

---

## What Word Always Changes (ACCEPT)

1. **lastRenderedPageBreak** — Requires pagination engine
2. **Zoom percent** — Word recalculates
3. **rsid entries** — Word adds new rsids
4. **Timestamps** — `modified` always overwritten
5. **Page count** — Requires layout engine
