---
title: BUG 008 - Term designations duplicated (semantic + fmt- both rendered)
priority: P1
status: closed
---

# BUG 008: Term Designations Duplicated

## Symptom

Every term entry shows the preferred name, admitted synonyms, and
deprecated synonyms twice — once from the semantic element and once
from the formatted element:

```
3.1
paddy                                  ← fmt-preferred
paddy ricerough rice                   ← fmt-admitted (concatenated!)
paddy                                  ← semantic preferred (duplicate)
paddy rice                             ← semantic admitted 1 (duplicate)
rough rice                             ← semantic admitted 2 (duplicate)
rice retaining its husk after threshing ← definition
```

## Root Cause

The adapter renders both the formatted children AND the semantic
children of a term:

```ruby
def visit_term(term, doc)
  fmt_name = term.fmt_name
  # ... render fmt_name

  preferred = term.fmt_preferred || term.preferred
  Array(preferred).each { |pref| render_term_name(...) }

  admitted = term.fmt_admitted || term.admitted
  Array(admitted).each { |adm| render_term_name(...) }

  deprecates = term.fmt_deprecates || term.deprecates
  Array(deprecates).each { |dep| render_term_name_with_prefix(...) }

  render_term_definitions(term, doc)
  render_term_notes(term, doc)
  render_term_examples(term, doc)

  walk_mixed_content(term, doc)        # ← renders EVERYTHING AGAIN
end
```

The final `walk_mixed_content(term, doc)` re-walks all of `term`'s
children in element_order — including the semantic `<preferred>`,
`<admitted>`, `<deprecates>`, `<definition>`, etc. that were already
rendered (or skipped) via the explicit visitor methods above.

The presentation XML provides BOTH semantic and formatted versions:

```xml
<term>
  <fmt-name>3.1</fmt-name>
  <preferred>...paddy...</preferred>
  <fmt-preferred>...paddy...</fmt-preferred>
  <admitted>...paddy rice...</admitted>
  <admitted>...rough rice...</admitted>
  <fmt-admitted>...paddy rice...rough rice...</fmt-admitted>
  <definition>...</definition>
  <fmt-definition>...</fmt-definition>
</term>
```

The adapter uses the `fmt-` versions for the explicit visitors but
then `walk_mixed_content` walks ALL children — picking up the
semantic versions a second time.

## Fix

Remove `walk_mixed_content(term, doc)` from `visit_term`. The explicit
visitors already cover all the formatted content that should be
rendered.

If there's a need to walk leftover content (e.g., fmt-* children that
don't have a dedicated visitor), filter the walk to skip elements
that have already been rendered (preferred, admitted, deprecates,
definition, termnote, termexample, fmt-name, fmt-preferred, fmt-admitted,
fmt-deprecates, fmt-definition).

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` `visit_term` — remove
  `walk_mixed_content(term, doc)` or replace with a filtered walk

## Related

This same semantic+fmt- duplication pattern also causes:
- BUG 011: CAUTION/WARNING duplication
- BUG 013: Cross-reference "Reference" prefix duplication
- BUG 018: Definition appearing only via walk_mixed_content
