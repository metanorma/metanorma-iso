# TODO 003: Render Amend Content from Raw XML

## Status: COMPLETE

### What

Implement `render_amend_content_block` — the core helper that parses raw XML from `AmendContentBlock.content` and renders each child element. Also implement per-element renderers.

### Why

`AmendContentBlock` stores content as raw XML string (`map_all_content to: :content`), not typed model attributes. We must parse the raw XML with Nokogiri and render each element.

### Changes

**`lib/isodoc/iso/docx/adapter.rb`** — add these methods:

1. `AMEND_BLOCK_RENDERERS` constant — maps element names to renderer methods
2. `render_amend_content_block(raw_xml, doc, style:)` — Nokogiri fragment parse + dispatch
3. `render_amend_paragraph(element, doc, style)` — render `<p>` as paragraph
4. `render_amend_note(element, doc, style)` — render `<note>` with "NOTE" prefix
5. `render_amend_subclause(element, doc, style)` — render `<clause>` (for added annexes)
6. `render_amend_text(text, doc, style)` — fallback for unknown elements
7. `render_amend_description(amend, doc)` — iterate description AmendContentBlocks
8. `render_amend_newcontent(amend, doc)` — iterate new_content AmendContentBlocks

### Content types in actual DAMD document

| Element | Count | Renderer |
|---------|-------|----------|
| `<p>` | ~20 | render_amend_paragraph |
| `<note>` | 1 | render_amend_note |
| `<table>` | 0 | (use existing visit_table if model-parsed) |
| `<figure>` | 1 | (use existing visit_figure if model-parsed) |
| `<clause type="annex">` | 1 | render_amend_subclause |

### Style decisions

- Description paragraphs: body style (no indent)
- Newcontent paragraphs: amend_newcontent style (indented)
- Newcontent notes: note style with "NOTE" prefix
- Subclause titles: amend_heading style
