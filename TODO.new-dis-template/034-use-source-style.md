# TODO 034: Use Source Style for Source Citations

## Status: DONE

## What

Source citations (e.g., "[1] ISO 712:...", "Source: ISO 24333") should use the `Source` style. The adapter currently renders them as `BodyText`.

## Why

### Current

```xml
<w:pStyle w:val="BodyText"/>
<w:t>ISO 712 (all parts)</w:t>
```

### Expected (Repaired)

```xml
<w:pStyle w:val="Source"/>
<w:t>[1] ISO 712 (all parts)</w:t>
```

The repaired output has 9 `Source` paragraphs; our output has 0.

## Architecture

1. Detect source citation paragraphs in the model (elements with `class="Source"` or `<source>` tags)
2. Use `Source` style instead of `BodyText`
3. Ensure `[N]` reference number prefixes are included in the text

## Files

- `lib/isodoc/iso/docx/adapter.rb` — source rendering
- `data/iso-dis/style_mapping.yml` — add source mapping (already exists)

## Depends On

- None
