---
title: BUG 005 - TermNum auto-numbering duplicated
priority: P1
status: closed
---

# BUG 005: TermNum Auto-Numbering Duplicated

## Symptom

Every term entry shows its number twice:

```
3.1
paddy
...
3.2
husked rice
```

Word renders "3.1" both as the auto-numbered TermNum paragraph and as
text inside that paragraph.

## Root Cause

Same root cause as BUG 004. The `TermNum` paragraph style in the DIS
template carries `<w:numPr>` for auto-numbering. The adapter writes the
term number ("3", ".", "1") as three separate text runs from the
presentation XML's `<fmt-name>`:

```xml
<w:p>
  <w:pPr><w:pStyle w:val="TermNum"/></w:pPr>
  <w:bookmarkStart w:id="2" w:name="paddy"/>
  <w:bookmarkEnd w:id="2"/>
  <w:r><w:t>3</w:t></w:r>
  <w:r><w:t>.</w:t></w:r>
  <w:r><w:t>1</w:t></w:r>
</w:p>
```

Word renders: auto-number "3.1" + text "3.1" = "3.13.1".

## Source of Bug

`lib/isodoc/iso/docx/adapter.rb` `visit_term` renders `term.fmt_name`
verbatim:

```ruby
fmt_name = term.fmt_name
if fmt_name
  name_para = Uniword::Builder::ParagraphBuilder.new
  name_para.style = @resolver.paragraph_style(:term_num)
  insert_bookmark(term, name_para)
  @inline_renderer.render(fmt_name, name_para)
  doc << name_para
end
```

The `fmt_name` contains the autonum semx elements which produce the
text "3.1".

## Fix

When `term_num` style has auto-numbering in the template, skip the
autonum content in `fmt_name` rendering. The simplest approach is to
reuse the heading-rendering path that strips autonum carriers.

Alternatively, if TermNum does NOT auto-number (and the user wants the
adapter to emit the number explicitly), then remove the `numPr` from
the TermNum style in the template — but this would diverge from the
reference DIS template.

## Verification

Check `styles.xml` for `TermNum`:

```xml
<w:style w:styleId="TermNum">
  <w:pPr>
    <w:numPr><w:numId w:val="..."/></w:numPr>
    ...
```

If `numPr` is present → strip autonum text from `fmt_name`.
If absent → adapter correctly emits the number.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` `visit_term` — strip autonum from
  `fmt_name` rendering when style auto-numbers
