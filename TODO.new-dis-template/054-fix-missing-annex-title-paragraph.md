# TODO 054: Fix Annex Title Rendering — ANNEX Paragraph Missing from Output

## Status: TODO

## What

The top-level ANNEX paragraph is missing from the output. Annex content starts directly with `a2` subclauses instead of with an `ANNEX` style paragraph. Also, variant-title-toc paragraphs are missing.

## Why

### Reference (rice.docx)
```
 219: (none)                    | [BR]  ← page break
 220: ANNEX                     | [BR](normative) [BR][BR]Determination of defects
 221: variant-title-toc         | Annex ADetermination of defects
 222: a2                        | A.1Principle
```

### Our Output
```
 185: BodyText  | The packages shall be marked...
 186: a2        | A.1[TAB]Principle  ← NO ANNEX PARAGRAPH BEFORE THIS
```

### Root Cause

Looking at `visit_annex`:
```ruby
def visit_annex(annex, doc, index)
  @context.with_annex do
    @context.section_depth = 1
    render_annex_title(annex, doc, index)
    walk_mixed_content(annex, doc)
  end
end
```

And `render_annex_title`:
```ruby
def render_annex_title(annex, doc, index)
  title_text = extract_annex_title_text(annex)
  return unless title_text  # ← MAY BE RETURNING NIL
  ...
end
```

The `extract_annex_title_text` method tries to find the title after the last `<br/><br/>` pair in the fmt-title. If this fails, it falls back to `collect_text(title)`. If the title is empty after stripping, it returns nil, causing `render_annex_title` to skip rendering.

But the variant-title-toc paragraphs are also missing. The `render_annex_variant_title_toc` is called at the end of `render_annex_title`, which exits early if `title_text` is nil.

Also, `walk_mixed_content(annex, doc)` walks the annex's content, which includes subclauses. The subclauses render as `a2`/`a3` headings because `@context.section_depth` is 1 and we're in annex context. But the top-level annex title paragraph is skipped.

Need to debug why `extract_annex_title_text` returns nil for the rice presentation XML annexes.

## Architecture

1. Debug `extract_annex_title_text` for the rice presentation XML annexes
2. Ensure `render_annex_title` always produces an ANNEX paragraph even when title extraction fails
3. Ensure `render_annex_variant_title_toc` is called even when title extraction fails

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `render_annex_title`, `extract_annex_title_text`, `render_annex_variant_title_toc`

## Depends On

- None
