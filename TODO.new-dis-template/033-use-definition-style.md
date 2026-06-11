# TODO 033: Use Definition Style for Definition List Descriptions

## Status: DONE

## What

The adapter renders definition list descriptions (`<dd>` elements) as `BodyText` paragraphs. The repaired output uses the `Definition` style for these.

## Why

### Current

```xml
<w:pStyle w:val="BodyText"/>
<w:t>consisting of a conical sample divider or multiple-slot sample divider...</w:t>
```

### Expected (Repaired)

```xml
<w:pStyle w:val="Definition"/>
<w:t>consisting of a conical sample divider or multiple-slot sample divider...</w:t>
```

The repaired output has 15 `Definition` paragraphs; our output has 0.

## Architecture

In `visit_definition_list` (or wherever `<dl>/<dd>` content is rendered), use `Definition` style for `dd` content instead of `BodyText`. Add `:definition` to style mapping.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — definition list rendering
- `data/iso-dis/style_mapping.yml` — add definition mapping (already exists)

## Depends On

- None
