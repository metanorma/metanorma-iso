# TODO 037: Add Cover Page Date Line

## Status: DONE

## What

The cover page is missing a "Date: YYYY-MM-DD" line that appears in the repaired output between the edition line and the title.

## Why

### Current (Latest Output)

```
zzCoverlarge: ISO 17301-1:2016
zzCover: 2nd edition
zzCover: (blank)
CoverTitleA1: Cereals and pulses — Specifications and test methods
CoverTitleA2: Rice (Final)
```

### Expected (Repaired Output)

```
zzCoverlarge: ISO/DIS 17301-1:2023
zzCover: 3rd edition
zzCover: (blank)
zzCover: Date: 2023-02-01
CoverTitleA1: Cereals and pulses — Specifications and test methods
CoverTitleA2: Part 1: Rice (DIS)
```

The "Date:" line uses `zzCover` style.

## Architecture

In `render_cover`, after the edition line, add a "Date: YYYY-MM-DD" line using `zzCover` style. Extract the date from `bibdata.date`.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `render_cover` method

## Depends On

- None
