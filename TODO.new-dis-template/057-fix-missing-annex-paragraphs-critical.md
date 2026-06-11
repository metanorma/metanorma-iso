# TODO 057: Critical — Debug and Fix Missing ANNEX Paragraphs

## Status: TODO

## What

The ANNEX style paragraphs are missing from the output. Annex content starts directly with `a2` subclauses (e.g., `A.1Principle`) instead of an `ANNEX` style paragraph containing the annex letter, obligation, and title.

## Why

### Reference (rice.docx)
```
 219: (none)       | [BR]                    ← page break before annex
 220: ANNEX        | [BR](normative) [BR][BR]Determination of defects
 221: variant-title-toc | Annex ADetermination of defects
 222: a2           | A.1Principle
```

### Our Output
```
 182: (none)       | The packages shall be marked...
 183: a2           | A.1Principle            ← NO ANNEX paragraph, NO page break
```

### Root Cause Analysis

The `render_annex_title` method extracts the title text using `extract_annex_title_text`. This method looks for the last `<br/><br/>` pair in the fmt-title's element_order and returns the text after it. If no br pair is found, it falls back to `collect_text(title)`.

For the rice presentation XML, the annex fmt-title has the structure:
```xml
<fmt-title>
  <strong><span class="fmt-caption-label"><span class="fmt-element-name">Annex</span> <semx>AnnexA</semx></span></strong>
  <br/>
  <span class="fmt-obligation">(normative)</span>
  <span class="fmt-caption-delim"><br/><br/></span>
  <semx element="title">Determination of defects</semx>
</fmt-title>
```

The `extract_annex_title_text` method finds the `<br/><br/>` pair inside the `<span class="fmt-caption-delim">` element. But the `<span>` wrapper means the br elements are children of the span, not direct children of the fmt-title. The method iterates the fmt-title's element_order, not the span's.

So the br pair is NOT found in the fmt-title's element_order (it's inside the span), `last_br_pair_end` stays nil, and the method falls back to `collect_text(title)` which returns something like "Annex A(normative)Determination of defects".

Wait — actually the method does return a non-nil value via the fallback. So `render_annex_title` should still produce an ANNEX paragraph. Let me check if the ANNEX paragraph is being created but with wrong content, or if it's being skipped entirely.

Actually, looking at the output: there's NO paragraph with `ANNEX` style at all between body content and the first `a2`. The `render_annex_title` is called by `visit_annex`, and if it produces a paragraph, it should appear. But it doesn't.

**Possible causes:**
1. `extract_annex_title_text` returns nil → `render_annex_title` returns without creating a paragraph
2. The ANNEX paragraph IS created but gets no style (and no text is visible)
3. The `visit_annex` method is not being called at all

Most likely cause: the model structure doesn't have separate annex objects. The annexes might be nested inside `sections` and get walked as regular clauses instead of being picked up by `visit_root`'s `model.annex` loop.

## Architecture

1. Debug: check if `model.annex` is populated for the rice presentation XML
2. If empty, the annexes are walked as part of `visit_sections` and the ANNEX heading never renders
3. Fix: either detect annexes during sections walk, or ensure the model properly populates the `annex` attribute

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `visit_root`, `visit_annex`, `visit_sections`
- `lib/isodoc/iso/docx/model_utils.rb` — model traversal

## Depends On

- None (this is the highest priority fix)
