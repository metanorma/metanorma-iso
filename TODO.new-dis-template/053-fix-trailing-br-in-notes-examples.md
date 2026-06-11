# TODO 053: Fix Trailing [BR] in Note/Example Rendering

## Status: TODO

## What

Notes and examples have trailing `[BR]` (line breaks) at the end of their text. The reference has no trailing line breaks.

## Why

### Reference (rice.docx)
```
 117: Note      | Note 1 to entry: The starch of waxy rice consists almost entirely...
 122: Example   | EXAMPLEForeign seeds, husks, bran, sand, dust.
```

### Our Output
```
  88: Note      | Note 1 to entry: The starch of waxy rice consists almost entirely...[BR]
  93: Example   | EXAMPLEForeign seeds, husks, bran, sand, dust.[BR]
 113: Note      | Note 1 to entry: It is expressed as a mass fraction...[BR]
```

### Root Cause

The trailing `[BR]` comes from the inline renderer rendering a `<br/>` element that appears at the end of the note/example content. In the presentation XML, the termnote may have:
```xml
<termnote>
  <fmt-name>Note 1 to entry: </fmt-name>
  <p>The starch of waxy rice...</p>
</termnote>
```

But looking more carefully, the trailing `[BR]` might come from the fmt-name or from an inline br element within the note's content. The issue is that the inline renderer doesn't strip trailing br elements.

## Architecture

In the inline renderer, after rendering all content for a note/example, strip trailing br runs from the paragraph model. Or, in the adapter's note/example rendering, clean up the paragraph before adding it.

## Files

- `lib/isodoc/iso/docx/inline.rb` — rendering of inline content
- `lib/isodoc/iso/docx/adapter.rb` — `visit_note`, `visit_example`, `render_term_notes`, `render_term_examples`

## Depends On

- None
