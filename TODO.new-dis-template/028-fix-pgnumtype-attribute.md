# TODO 028: Fix pgNumType Attribute Name — w:format vs w:fmt

## Status: DONE

## What

The adapter uses `w:format="lowerRoman"` for page number format, but the DIS template uses `w:fmt="lowerRoman"`. The correct OOXML attribute name is `w:fmt`.

## Why

### Current (Broken)

```xml
<w:pgNumType w:format="lowerRoman"/>
```

### Expected (DIS Template)

```xml
<w:pgNumType w:fmt="lowerRoman"/>
```

The OOXML specification uses `w:fmt` not `w:format` for the `<w:pgNumType>` element. Using the wrong attribute name may cause Word to ignore the roman numeral formatting.

## Architecture

Fix the attribute name in `insert_section_break`. This is likely a Uniword serialization issue — check if Uniword uses the wrong attribute name for `PageNumberType`.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `insert_section_break` method
- Possibly Uniword page number type attribute naming

## Depends On

- None
