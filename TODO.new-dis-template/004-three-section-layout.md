# TODO 004: Three-Section Document Layout

## Status: COMPLETE

## What

Implement the three-section document layout (cover → front matter → body) with correct page numbering, headers, and footers for each section.

## Why

The reference DOCX has 3 sections with different page numbering (none → roman → arabic), headers (none → centered doc ID → centered doc ID), and footers (none → copyright + roman page → copyright + arabic page). The current adapter generates a flat document without section breaks.

## Reference Structure

```
Section 1 (Cover):
  - No headers
  - No footers
  - No page numbering
  - Content: zzCoverlarge, zzCover, CoverTitleA1/A2, zzCopyright, zzCopyrightaddress
  - Terminates with PAGEBREAK paragraph

Section 2 (Front matter):
  - HeaderCentered (even + odd): "ISO/DIS 15926-100:2025(en)"
  - FooterCentered: "© ISO 2025 – All rights reserved"
  - FooterPageRomanNumber: PAGE field (roman numerals)
  - pgNumType: fmt=lowerRoman
  - Content: TOC, Foreword, Introduction
  - Terminates with PAGEBREAK paragraph

Section 3 (Body):
  - HeaderCentered (even + odd): "ISO/DIS 15926-100:2025(en)"
  - FooterCentered: "© ISO 2025 – All rights reserved"
  - FooterPageNumber: PAGE field (arabic)
  - pgNumType: start=1
  - Content: MainTitle, Heading1..6, terms, annexes, bibliography
```

## Architecture

### Section Properties in OOXML

Each section break is a `<w:sectPr>` element either:
1. As the last child of a `<w:p>` (`w:pPr/w:sectPr`) — inline section break
2. As the last child of `<w:body>` — final section properties

### Approach: Section-Aware Rendering

The adapter already walks the document tree sequentially. We need to:

1. **Track current section** in `Context` (cover/front_matter/body)
2. **Insert section breaks** at the right transitions
3. **Set section properties** (page numbering, header/footer references)

```ruby
class Context
  attr_accessor :current_section  # :cover, :front_matter, :body

  def cover?
    current_section == :cover
  end

  def front_matter?
    current_section == :front_matter
  end
end
```

### Header/Footer Content

Headers and footers come from the template DOCX. The template provides 4 header files and 4 footer files. The adapter should:

1. Preserve header/footer content from the template (it has placeholder text)
2. Update the header text to match the actual document identifier
3. Keep footer copyright and page numbering as-is

### Page Numbering

- Section 1 (cover): no page numbers
- Section 2 (front): `lowerRoman` format
- Section 3 (body): arabic, `start=1`

## Implementation Details

### In the Adapter

When rendering cover page elements (first clause/title), set `context.current_section = :cover`.

After cover page content, insert a section break paragraph:
```ruby
def insert_section_break(doc, section_type)
  para = doc.create_paragraph
  para.style = "PAGEBREAK"
  # Set section properties on the paragraph
  para.section_properties = build_section_properties(section_type)
  doc << para
end
```

The `build_section_properties` method creates the appropriate `<w:sectPr>` with:
- Header/footer references to the correct headerN.xml / footerN.xml
- Page numbering format
- Page margins (same for all sections in ISO template)

## Files

- `lib/isodoc/iso/docx/context.rb` — add section tracking
- `lib/isodoc/iso/docx/adapter.rb` — insert section breaks, set section properties
- `data/iso-dis/template.docx` — ensure headers/footers are present

## Depends On

- TODO 002 (new template with correct header/footer files)
