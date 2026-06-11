# TODO 044: Fix Warning Block Position and Style

## Status: DONE

## What

The warning block ("Warning for WDs and CDs") appears AFTER the TOC with `(none)` style instead of BEFORE the TOC with `zzwarninghdr`/`zzwarning` styles. In the reference, the warning block appears between the cover and the section break (before the copyright page).

## Why

### Reference (rice.docx)
```
   7: (none)                    | CD stage
   8: (none)                    | 
   9: zzwarninghdr              | Warning for WDs and CDs
  10: zzwarning                 | This document is not an ISO International Standard...
  11: zzwarning                 | Recipients of this draft are invited to submit...
  12: (none)                    | 
  13: (none)                    |  [SECT: fmt= start=]
  14: zzCopyright               | © ISO 2016
```

### Our Output
```
  15: zzCopyrightaddress        | Published in Switzerland
  16: PAGEBREAK                 |  [SECT: fmt= start=]
  17: zzContents                | Contents
  18: TOC1                      | 
  19: (none)                    | Warning for WDs and CDs
  20: (none)                    | This document is not an ISO International Standard...
  21: (none)                    | Recipients of this draft are invited to submit...
  22: ForewordTitle             | Foreword
```

### Key Issues
1. **Position**: Warning appears after TOC in our output; should appear before TOC (between cover and copyright section break)
2. **Style**: Warning uses `(none)` style; should use `zzwarninghdr` for title and `zzwarning` for body paragraphs

## Root Cause

In `adapter.rb` `visit_root`, the order is:
```ruby
render_cover(model, doc)
render_copyright_block(model, doc)
insert_section_break(doc, :cover)
render_toc(model, doc)
render_warning(model, doc)  # ← AFTER TOC
```

Should be:
```ruby
render_cover(model, doc)
render_warning(model, doc)  # ← BEFORE section break
render_copyright_block(model, doc)
insert_section_break(doc, :cover)
render_toc(model, doc)
```

Also, the `render_warning` method uses `styled_para(:warning_header)` and `styled_para(:warning)` which look up the style mapping. The mapping has `warning_header: zzwarninghdr` and `warning: zzwarning`. But `styled_para` may return a builder without a style if the resolver returns nil.

## Architecture

1. Move `render_warning` call before `insert_section_break(doc, :cover)` in `visit_root`
2. Verify `styled_para` correctly resolves `:warning_header` → `zzwarninghdr` and `:warning` → `zzwarning`

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `visit_root` method ordering, `render_warning` method

## Depends On

- None
