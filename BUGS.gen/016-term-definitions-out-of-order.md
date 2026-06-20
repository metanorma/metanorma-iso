---
title: BUG 016 - Term definitions only rendered via fallback walk
priority: P1
status: closed
---

# BUG 016: Term Definitions Only Rendered via Fallback Walk

## Symptom

Term definitions appear OUT OF ORDER — after the notes instead of
right after the preferred name — and only because of a duplicate
walk_mixed_content pass:

```
3.5
waxy rice
Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin...

waxy rice                              ← duplicate preferred
variety of rice whose kernels have...  ← definition (late!)
```

## Root Cause

The adapter calls `render_term_definitions(term, doc)` which does:

```ruby
def render_term_definitions(term, doc)
  Array(term.definition).each { |defn| walk_mixed_content(defn, doc) }
end
```

But `term.definition` returns the semantic `<definition>` element,
whose content is a `<verbal-definition>` wrapper containing the `<p>`:

```xml
<definition>
  <verbal-definition>
    <p>variety of rice whose kernels...</p>
  </verbal-definition>
</definition>
```

The `walk_mixed_content` call on the `<definition>` doesn't know how
to dispatch `<verbal-definition>` (it's not in the case/when in
`visit_block`), so it falls through to `walk_mixed_content`'s else
branch which silently produces nothing.

The definition text only emerges later, during the
`walk_mixed_content(term, doc)` call at the end of `visit_term`, which
walks the `<fmt-definition>` element (whose content IS a direct `<p>`
without the verbal-definition wrapper).

## Fix

Three changes needed:

1. **Render `fmt-definition` instead of `definition`** (matching the
   pattern used for `fmt-preferred` / `fmt-admitted`). The fmt-
   version has a direct `<p>` child that the adapter can render.

2. **Add `verbal-definition` (and any other definition wrappers) to
   the visit_block dispatch** so the semantic version would also
   render correctly if used as fallback.

3. **Once (1) and (2) are in place, remove the trailing
   `walk_mixed_content(term, doc)`** that causes the duplicate
   preferred/definition rendering.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` `render_term_definitions` — prefer
  `term.fmt_definition`
- `lib/isodoc/iso/docx/adapter.rb` `visit_block` — add dispatch for
  `Metanorma::Document::Components::Definitions::VerbalDefinition`
  (or whatever the class name is)

## Related

- BUG 008: same family — term children duplicated by trailing walk
