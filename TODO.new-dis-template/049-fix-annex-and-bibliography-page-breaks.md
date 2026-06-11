# TODO 049: Add Page Breaks Before Annexes and Bibliography

## Status: TODO

## What

Annexes and the Bibliography section should start on new pages. The reference has empty `[BR]` paragraphs before each ANNEX heading (acting as page breaks via the ANNEX style's `pageBreakBefore` property). The Bibliography heading uses `BiblioTitle` style which also has `pageBreakBefore`.

## Why

### Reference (rice.docx)
```
 218: (none)                    | The packages shall be marked...
 219: (none)                    | [BR]         ← page break paragraph before Annex A
 220: ANNEX                     | [BR](normative) [BR][BR]Determination of defects
 ...
 254: (none)                    | Report the results...
 255: ANNEX                     | [BR](informative) [BR][BR]Determination of waxy rice...
 ...
 300: (none)                    | Report the results...
 301: ANNEX                     | [BR](informative) [BR][BR]Gelatinization
 ...
 315: ANNEX                     | [BR](informative) [BR][BR]Extraneous information
 ...
 330: (none)                    | [BR]         ← page break paragraph before Bibliography
 331: BiblioTitle               | Bibliography
```

### Our Output
```
 184: Heading1  | 9[TAB]Marking
 185: BodyText  | The packages shall be marked...
 186: a2        | A.1[TAB]Principle  ← NO PAGE BREAK, NO ANNEX PARAGRAPH
 ...
 219: BodyText  | Report the results...
 220: a2        | B.1[TAB]Principle  ← NO PAGE BREAK, NO ANNEX PARAGRAPH
 ...
 275: Tabletitle | Key
 276: BiblioTitle | Bibliography  ← NO PAGE BREAK before this
```

### Key Issues

1. **Missing ANNEX paragraphs**: Our output goes directly from body to `a2` subclauses — there's no `ANNEX` style paragraph for the annex title. The `visit_annex` method calls `render_annex_title` which should create the ANNEX paragraph, but it's not appearing.

2. **No page breaks before annexes**: Even if ANNEX paragraphs were present, there are no page break paragraphs.

3. **No page break before Bibliography**: `BiblioTitle` should have `pageBreakBefore` in the template, but it doesn't appear to be taking effect. Or the style in the template may not have this property.

4. **Annex rendering order**: The `visit_root` iterates `model.annex.each_with_index { |a, i| visit_annex(a, doc, i) }`. But the `visit_annex` method starts at depth=1, and the first subclause gets `a2` style (depth 1 maps to annex_heading2=a2). The top-level ANNEX title is rendered by `render_annex_title`.

Need to investigate why ANNEX paragraphs are missing from the output.

## Architecture

1. Debug why `render_annex_title` is not producing ANNEX-style paragraphs
2. Ensure each annex starts with an ANNEX paragraph before its subclauses
3. The `BiblioTitle` style should handle page breaks via its `pageBreakBefore` property
4. If ANNEX style has `pageBreakBefore`, no explicit page break paragraph is needed

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `visit_annex`, `render_annex_title`, `visit_remaining_bibliography`

## Depends On

- None
