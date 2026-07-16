# 067: Fix Missing rStyle (Run-Level Styles)

## Problem
The reference uses 30+ distinct run-level styles (rStyle) for semantic formatting. The output uses only `Hyperlink` rStyle (6 occurrences). All other run-level styling is missing.

## Evidence
```
Reference rStyle usage (top entries):
  177 × msotoctextspan1     (TOC text spans)
  174 × Hyperlink           (hyperlinks)
   99 × stem                (math/formula)
   65 × zzmovetofollowing   (change tracking?)
   44 × stdpublisher0       (ISO publisher)
   44 × stddocnumber        (document number)
   40 × stdyear             (year)
   32 × FootnoteReference   (footnotes)
   25 × citesec             (section citations)
   18 × citeapp             (annex citations)
   17 × stddoctitle         (document title)
   16 × stddocpartnumber    (part number)
   10 × notelabel           (note labels)
    7 × citefig             (figure citations)
    5 × termnotelabel       (term note labels)
    5 × tablefootnoteref    (table footnote refs)
    5 × citetbl             (table citations)
    ... (15 more styles)

Output rStyle usage:
    6 × Hyperlink
```

That's it. No stem, no stdpublisher0, no stddocnumber, no FootnoteReference, no notelabel, no citesec, etc.

## Impact
- Math formulas lose their formatting (no `stem` rStyle)
- Cross-references lose semantic styling (no `citesec`, `citeapp`, `citefig`, `citetbl`)
- Document metadata elements lose formatting (no `stdpublisher0`, `stddocnumber`, `stdyear`)
- Footnote references lose their superscript formatting (no `FootnoteReference` rStyle)
- Note labels lose bold formatting (no `notelabel`, `termnotelabel`)

## Fix
Add rStyle assignment during inline rendering. The style_resolver should map semantic contexts to appropriate rStyle values. Key mappings:
- `<stem>` → `stem`
- `<eref>` → `stdpublisher0`, `stddocnumber`, `stdyear`
- `<xref>` → `citesec`, `citeapp`, `citefig`, `citetbl`
- `<fn>` → `FootnoteReference`
- Note/example labels → `notelabel`, `examplelabel`, `termnotelabel`

## Priority
**HIGH** — Loss of run-level formatting affects all inline semantic elements.

## Location
- `lib/isodoc/iso/docx/inline.rb` — inline element rendering
- `lib/isodoc/iso/docx/style_resolver.rb` — style mapping
- `data/iso-dis/style_mapping.yml` — rStyle mappings
