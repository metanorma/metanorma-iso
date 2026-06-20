---
title: BUG 006 - ANNEX title duplicated
priority: P1
status: closed
---

# BUG 006: ANNEX Title Duplicated

## Symptom

Each annex heading appears with "Annex X" twice:

```
Annex AAnnex A
(normative)

Determination of defects
```

## Root Cause

Same root cause as BUG 004. The `ANNEX` paragraph style auto-numbers
via `<w:numPr>` in the DIS template.

The adapter's `render_annex_title` writes "Annex A" + "(normative)" +
"Determination of defects" as text runs:

```xml
<w:p>
  <w:pPr><w:pStyle w:val="ANNEX"/></w:pPr>
  <w:r><w:rPr><w:b/></w:rPr><w:t>Annex A</w:t></w:r>
  <w:r><w:br/></w:r>
  <w:r><w:t>(normative)</w:t></w:r>
  <w:r><w:br/></w:r>
  <w:r><w:br/></w:r>
  <w:r><w:rPr><w:b/></w:rPr><w:t>Determination of defects</w:t></w:r>
</w:p>
```

Word renders: auto-label "Annex A" + text "Annex A" = "Annex AAnnex A".

## Source of Bug

`lib/isodoc/iso/docx/adapter.rb` `render_annex_title`:

```ruby
def render_annex_title(annex, doc)
  title = annex.fmt_title || annex.title
  return unless title

  para = Uniword::Builder::ParagraphBuilder.new
  para.style = @resolver.paragraph_style(:annex)
  insert_bookmark(annex, para)
  @inline_renderer.render(title, para)
  doc << para
end
```

The `fmt_title` for an annex contains:
```xml
<fmt-title>
  <fmt-caption-label>Annex <semx element="autonum">A</semx></fmt-caption-label>
  <fmt-caption-delim><tab/></fmt-caption-delim>
  <semx element="title">Determination of defects</semx>
  <semx element="obligation">normative</semx>
</fmt-title>
```

The autonum "A" is rendered as text → "Annex A" leaks through.

## Fix

When rendering an annex title with the `ANNEX` style (which
auto-numbers), strip the autonum content. The style will produce the
"Annex A" prefix on its own.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` `render_annex_title` — strip autonum
  carriers from the title rendering
