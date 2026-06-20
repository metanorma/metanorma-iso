---
title: BUG 010 - Bibliography entries missing formattedref (no title)
priority: P1
status: closed
---

# BUG 010: Bibliography Entries Missing Formattedref (No Title)

## Symptom

Every bibliography entry shows the citation label and identifier but
no actual title:

```
[1]    ISO 2146:1988,
[2]    ISO 3696:1987,
[3]    ISO 5725-1:1994,
[4]    ISO 5725-2:1994,
```

The reference TITLE is missing entirely.

## Root Cause

The presentation XML provides TWO elements per bibitem:

```xml
<bibitem>
  <biblio-tag>[1]<fn/>...<tab/>ISO 2146:1988, </biblio-tag>
  <formattedref>
    <em><span class="stddocTitle">Documentation — Directories of libraries...</span></em>
  </formattedref>
  ...
</bibitem>
```

The `biblio-tag` carries the ordinal `[1]` + footnote + tab + bare
identifier `ISO 2146:1988, ` (note the trailing comma, no title).

The `formattedref` carries the human-readable citation WITH the title.

The adapter only renders the `biblio-tag` and never emits the
`formattedref` content.

## Source of Bug

`lib/isodoc/iso/docx/adapter.rb` `visit_bibliographic_item` (or
whatever walks bibitems) renders only the biblio-tag element. It does
not also render formattedref.

## Evidence

```xml
<w:p>
  <w:pPr><w:pStyle w:val="BiblioEntry"/></w:pPr>
  <w:bookmarkStart w:id="87" w:name="ISO2146"/>
  <w:bookmarkEnd w:id="87"/>
  <w:r><w:t>[1]</w:t></w:r>
  <w:r><w:rPr><w:rStyle w:val="FootnoteReference"/></w:rPr>
     <w:footnoteReference w:id="1"/></w:r>
  <w:r><w:br/></w:r>
  <w:r><w:tab/></w:r>
  <w:r><w:rPr/><w:t>ISO</w:t></w:r>
  <w:r><w:t> </w:t></w:r>
  <w:r><w:rPr/><w:t>2146</w:t></w:r>
  <w:r><w:t>:</w:t></w:r>
  <w:r><w:rPr/><w:t>1988</w:t></w:r>
  <w:r><w:t xml:space="preserve">, </w:t></w:r>
  <!-- NOTHING FOLLOWS — no formattedref content -->
</w:p>
```

## Fix

After rendering the biblio-tag, also render the `formattedref` content
into the same paragraph (no paragraph break — the formattedref is part
of the same entry).

The `formattedref` contains an `<em>` wrapper for the italic title
styling, so the inline renderer needs to honor the italic emphasis
and the `stddocTitle` character style.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — `visit_bibliographic_item`
  should render both `biblio_tag` AND `formattedref` content

## Also Note

The `<w:br/>` between `[1]` and the tab is suspicious — likely an
unwanted artifact of how the biblio-tag is being rendered (a literal
newline in the source being converted to a line break). Worth
investigating in the same fix.
