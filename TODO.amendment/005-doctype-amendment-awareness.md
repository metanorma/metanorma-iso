# TODO 005: Add Doctype Amendment Awareness

## Status: PENDING

### What

Add doctype detection to the adapter so amendment documents get appropriate rendering:
- Suppress heading numbers for amendment clause titles
- Use `zzSTDTitle2` style for middle title (amendment title line)
- No TOC title for amendments

### Changes

1. **`lib/isodoc/iso/docx/adapter.rb`** — detect doctype from bibdata:
   ```ruby
   def amendment?(model)
     doctype = model.bibdata&.doctype rescue nil
     %w[amendment technical-corrigendum].include?(doctype&.downcase)
   end
   ```

2. **`lib/isodoc/iso/docx/adapter.rb`** — modify `visit_root`:
   - Skip `render_toc` for amendment documents
   - Set context flag for amendment rendering

3. **`lib/isodoc/iso/docx/context.rb`** — add `in_amendment` flag

4. **`lib/isodoc/iso/docx/adapter.rb`** — modify `render_section_title`:
   - Use different style for amendment clause headings (no numbering)

### Reference

Old converter behavior for amendments:
- `@suppressheadingnumbers = true` globally
- Re-enable heading numbers inside amend newcontent
- TOC title suppressed
- Middle title uses `zzSTDTitle2` class
- Word DIS: all h1 in main section → italic paragraphs
