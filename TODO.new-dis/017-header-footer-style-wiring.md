# 017 — Header/footer style wiring

## Problem

DIS 15926 Era C defines `HeaderCentered`, `FooterCentered`,
`FooterPageNumber`, `FooterPageRomanNumber`, `FooterCenteredContinued`.
These are mapped in YAML but not yet used in code — the adapter doesn't
have a `HeaderFooterRenderer` that produces header/footer parts.

## Approach

Create a dedicated `HeaderFooterRenderer` that, given a document model
and a section, produces header/footer parts appropriate to the section's
page numbering scheme (roman for front matter, arabic for body,
different first page for cover).

### Section-aware rendering

`SectionManager` knows the page numbering scheme for each section.
`HeaderFooterRenderer` consults it:

```ruby
class HeaderFooterRenderer
  def initialize(resolver, context, section_manager)
    @resolver = resolver
    @context = context
    @section_manager = section_manager
  end

  def render_header(section, doc)
    style = @resolver.paragraph_style(:header_centered)
    para = build_paragraph(style: style)
    add_header_content(section, para)
    doc.add_header(section.id, para)
  end

  def render_footer(section, doc)
    scheme = @section_manager.page_number_scheme(section)
    style = footer_style_for(scheme)
    para = build_paragraph(style: style)
    add_page_number_field(para) if scheme.page_number?
    doc.add_footer(section.id, para)
  end

  private

  def footer_style_for(scheme)
    case scheme.format
    when :roman    then @resolver.paragraph_style(:footer_roman)
    when :arabic   then @resolver.paragraph_style(:footer_page_number)
    when :centered then @resolver.paragraph_style(:footer_centered)
    end
  end
end
```

### YAML additions (verify Era C defines these)

Current mapping has:
```yaml
header_centered: HeaderCentered
footer_centered: FooterCentered
footer_page_number: FooterPageNumber
footer_roman: FooterPageRomanNumber
```

DIS 15926 also has `FooterCenteredContinued` — for table-page-spanning
"Continued" footers. Add:
```yaml
footer_centered_continued: FooterCenteredContinued
```

## Files affected

- Modify: `data/iso-dis/style_mapping.yml` — add `footer_centered_continued`
- Create: `lib/isodoc/iso/docx/renderers/header_footer_renderer.rb`
- Modify: `lib/isodoc/iso/docx/section_manager.rb` — expose
  `page_number_scheme(section)` returning a `PageScheme` value object
  with `format` and `page_number?` methods.
- Modify: `lib/isodoc/iso/docx/adapter.rb` — invoke header/footer
  rendering at section breaks

## Acceptance criteria

- Cover page (front matter, roman numbering): footer uses
  `FooterPageRomanNumber` with current page field.
- Body sections (arabic): footer uses `FooterPageNumber`.
- Header for all sections: `HeaderCentered` with running title text.
- All styles flow from YAML; no string literals.

## Required specs

- `header_footer_renderer_spec.rb`:
  - Roman-numeral section → `FooterPageRomanNumber` paragraph with `<w:fldChar>` for page number.
  - Arabic section → `FooterPageNumber` paragraph.
  - Header always uses `HeaderCentered`.
- `section_manager_spec.rb`:
  - `page_number_scheme(cover_section)` returns roman scheme.
  - `page_number_scheme(body_section)` returns arabic scheme.
