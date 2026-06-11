# TODO 004: Add Amendment Styles to Style Mapping

## Status: COMPLETE

### What

Add amendment-specific DOCX styles to the DIS template style mapping.

### Changes

**`data/iso-dis/style_mapping.yml`** — add under `paragraph_styles:`:

```yaml
amend_newcontent: a3    # indented paragraph for amend newcontent
amend_heading: h        # heading for added annexes/clauses in amend newcontent
```

### Reference

Old Word DIS converter uses:
- `AMEND Terms Heading` — gray background, bold, 13pt
- `AMEND Heading 1 Unnumbered` — gray background, bold, 13pt
- Newcontent rendered as `<quote>` with `AmendNewcontent` CSS class
- Amendment headings outside newcontent: italic, normal weight

For now, use simple mappings. Refine after TODO 005 (doctype awareness).
