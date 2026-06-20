---
title: BUG 009 - Admitted synonyms concatenated without separator
priority: P1
status: closed
---

# BUG 009: Admitted Synonyms Concatenated Without Separator

## Symptom

When a term has multiple admitted synonyms, they are jammed together
into one paragraph with no separator:

```
paddy ricerough rice
```

Expected (per ISO house style):

```
paddy rice
rough rice
```

Each admitted designation on its own line (or with a delimiter like
"; " or " — " between them).

## Root Cause

The adapter renders `fmt-admitted` as a single paragraph via
`render_term_name`:

```ruby
admitted = term.fmt_admitted || term.admitted
Array(admitted).each do |adm|
  render_term_name(adm, doc, @resolver.paragraph_style(:alt_terms))
end
```

The `render_term_name` calls `@inline_renderer.render(designation, para)`
once for the whole `fmt-admitted` element. But the source
`fmt-admitted` contains MULTIPLE `<p>` elements — one per admitted
synonym:

```xml
<fmt-admitted>
  <p><semx element="admitted"><semx>paddy rice</semx></semx></p>
  <p><semx element="admitted"><semx>rough rice</semx></semx></p>
</fmt-admitted>
```

The inline renderer flattens both `<p>` children into the SAME
paragraph builder, producing:

```xml
<w:p>
  <w:r><w:t>paddy rice</w:t></w:r>
  <w:r><w:t>rough rice</w:t></w:r>
</w:p>
```

No separator, no line break.

## Fix

For `fmt-admitted` (and `fmt-deprecates`, `fmt-preferred` when
array-valued), iterate over the inner `<p>` elements and emit one
paragraph per inner `<p>`.

Two implementation paths:

1. Use `walk_mixed_content(admitted, doc)` instead of
   `render_term_name` when the designation is a wrapper with multiple
   children. This naturally creates one paragraph per child `<p>`.

2. Add a helper `render_term_designation_list(designation, doc, style)`
   that handles both single-designation and multi-designation cases.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — `visit_term` admitted/deprecates
  rendering
