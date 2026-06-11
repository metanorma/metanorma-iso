# TODO 042: Fix Whitespace Issues — Extra Spaces and Newlines

## Status: DONE

## What

Multiple whitespace issues throughout the output:
- "Note 1 to entry" has no space before the note text: "Note 1 to entryThe starch..."
- "EXAMPLE" has no space: "EXAMPLEForeign seeds..."
- URLs have extra spaces: "available at  http://..." (double space)
- "available athttp://" (no space before URL)

## Why

### Current (Broken)

```
Note: Note 1 to entryThe starch of waxy rice...
Example: EXAMPLEForeign seeds, husks, bran, sand, dust.
URL: ISO Online browsing platform: available at  http://www.iso.org/obp
URL: IEC Electropedia: available athttp://www.electropedia.org
```

### Expected (Reference)

```
Note: Note 1 to entry: The starch of waxy rice...
Example: EXAMPLE — Foreign seeds, husks, bran, sand, dust.
```

The whitespace issues come from the inline renderer not inserting proper spacing between elements.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — note/example rendering
- `lib/isodoc/iso/docx/inline.rb` — inline element rendering

## Depends On

- None
