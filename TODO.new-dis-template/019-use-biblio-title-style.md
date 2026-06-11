# TODO 019: Use BiblioTitle for Bibliography Heading

## Status: DONE

## What

The bibliography section uses `Heading2` style for its title, but it should use `BiblioTitle` style. The `BiblioTitle` style has `pageBreakBefore` which ensures the bibliography starts on a new page. `Heading2` does NOT have `pageBreakBefore`.

## Why

### Current (Broken)

```xml
<w:pStyle w:val="Heading2"/>
<w:t>Bibliography</w:t>
```

`Heading2` has no `pageBreakBefore` — bibliography runs directly after the last annex content.

### Expected (DIS Template)

```xml
<w:pStyle w:val="BiblioTitle"/>
<w:t>Bibliography</w:t>
```

`BiblioTitle` has `pageBreakBefore`, `spacing after="760"`, centered alignment — the bibliography always starts on a new page.

## Architecture

In the adapter's bibliography rendering, use `BiblioTitle` style instead of `Heading2`. The style mapping should map `:biblio_title` → `BiblioTitle`.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — bibliography rendering
- `data/iso-dis/style_mapping.yml` — add `biblio_title` mapping

## Depends On

- None
