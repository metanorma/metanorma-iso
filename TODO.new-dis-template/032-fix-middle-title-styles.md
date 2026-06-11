# TODO 032: Use MainTitle1/MainTitle2 for Middle Title Section

## Status: DONE

## What

The adapter uses `zzSTDTitle` for both middle title paragraphs. The repaired output uses `MainTitle1` for the document title and `MainTitle2` for the part/subtitle, plus a combined `zzSTDTitle` line.

## Why

### Current (Latest Output)

```xml
<w:pStyle w:val="zzSTDTitle"/>
<w:t>Cereals and pulses — Specifications and test methods</w:t>
<!-- second paragraph -->
<w:pStyle w:val="zzSTDTitle"/>
<w:t>Rice (Final)</w:t>
```

### Expected (Repaired/Reference Output)

```xml
<w:pStyle w:val="MainTitle1"/>
<w:t>Cereals and pulses — Specifications and test methods</w:t>
<!-- second paragraph -->
<w:pStyle w:val="MainTitle2"/>
<w:t>Part 1: Rice (DIS)</w:t>
<!-- third paragraph (combined) -->
<w:pStyle w:val="zzSTDTitle"/>
<w:t>Cereals and pulses — Specifications and test methods — Part 1: Rice (DIS)</w:t>
```

### Key Differences

1. **First line**: `MainTitle1` not `zzSTDTitle`
2. **Second line**: `MainTitle2` not `zzSTDTitle`
3. **Third line**: Combined text with `zzSTDTitle` style — full title with em-dash separator

## Architecture

Update `render_middle_title` to use three paragraphs:
1. `MainTitle1` with title-intro + title-main
2. `MainTitle2` with part prefix + title-part
3. `zzSTDTitle` with combined full title

Add `main_title1` and `main_title2` to style mapping.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `render_middle_title` method
- `data/iso-dis/style_mapping.yml` — add main_title1, main_title2 mappings

## Depends On

- None
