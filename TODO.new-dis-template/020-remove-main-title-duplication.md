# TODO 020: Remove MainTitle1/MainTitle2 — Use Only zzSTDTitle

## Status: DONE

## What

The adapter renders three title paragraphs in the body section: `MainTitle1`, `MainTitle2`, and `zzSTDTitle`. The DIS template only has `zzSTDTitle`.

## Why

### Current (Broken) Structure

```xml
<w:pStyle w:val="MainTitle1"/>
<w:t>Cereals and pulses — Specifications and test methods</w:t>

<w:pStyle w:val="MainTitle2"/>
<w:t>Part 1: Rice (DIS)</w:t>

<w:pStyle w:val="zzSTDTitle"/>
<w:t>Cereals and pulses — Specifications and test methods — Part 1:Rice (DIS)</w:t>
```

Three paragraphs for what should be one.

### Expected (DIS Template) Structure

```xml
<w:pStyle w:val="zzSTDTitle"/>
<w:t>Standard representation of food location</w:t>
```

Only `zzSTDTitle` — a single paragraph with the full document title. No `MainTitle1` or `MainTitle2`.

### The `zzSTDTitle` Role

In the DIS template, `zzSTDTitle` is the first paragraph of the body section (after the front matter section break). It contains the full document title. This is the title that appears at the top of page 1 (arabic numbering) before the first Heading1 clause.

## Architecture

Remove `MainTitle1` and `MainTitle2` rendering. Output only `zzSTDTitle` with the combined full title (intro + main + complement).

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `render_middle_title` or equivalent

## Depends On

- None
