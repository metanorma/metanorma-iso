# 03: XML-to-DOCX Adapter (Semantic Model → Uniword)

## Summary

Build an adapter that converts isodoc's semantic XML presentation model directly into Uniword model objects (Paragraph, Run, Table, etc.), producing a valid DOCX without any HTML intermediate.

## Motivation

The current DOCX path: XML → XSLT → HTML → html2doc → DOCX. The HTML intermediate is lossy — semantic information is flattened into CSS classes and HTML elements, then re-parsed back into OOXML. Going directly from XML to Uniword preserves fidelity and eliminates an entire conversion layer.

## Prerequisites

- 01: Architecture & Dependency Setup
- 02: ISO DOCX Template
- Uniword >= 1.0.6 (DocumentBuilder, all builders)

## Architecture

```
isodoc presentation XML
        │
        ▼
IsoDoc::DocxAdapter (new)
        │
        ├── loads ISO template (DocxPackage.from_file)
        ├── walks XML tree
        ├── maps elements to Uniword builders:
        │   <p>      → ParagraphBuilder
        │   <h1>..   → ParagraphBuilder with heading style
        │   <table>  → TableBuilder
        │   <ul>/<ol>→ ListBuilder
        │   <fn>     → FootnoteBuilder
        │   <image>  → ImageBuilder
        │   <stem>   → MathBuilder (OMML passthrough)
        │   <bookmark>→ bookmark on ParagraphBuilder
        │
        ▼
Uniword::Builder::DocumentBuilder
        │
        ▼
doc.save("output.docx")
```

## Tasks

### 1. Define the XML element → Uniword builder mapping

The adapter receives isodoc's presentation XML (already processed by XSLT). Key element mappings:

| XML Element | Uniword Builder | Notes |
|---|---|---|
| `<clause>`, `<p>` | `ParagraphBuilder` | Map `@class` → styleId |
| `<title>` | `ParagraphBuilder` with heading style | Level from nesting depth |
| `<table>` | `TableBuilder` | `<tr>` → `TableRowBuilder`, `<td>` → `TableCellBuilder` |
| `<ol>/<ul>` | `ListBuilder` | Type from `@type` attribute |
| `<fn>` | `FootnoteBuilder` | Via `doc.footnote(text)` |
| `<image>` | `ImageBuilder` | Via `doc.image(path)` |
| `<stem>` | Run with OMML | Passthrough from Plurimath |
| `<annotation>` | `CommentBuilder` | Via `doc.comment()` |
| `<bookmark>` | `doc.bookmark(name)` | Bookmark start/end |
| `<figure>`, `<note>`, `<example>` | Paragraphs with style | Container → styled paragraph |
| `<annex>` | Paragraph with annex style | Section break + style |
| `<bibliography>` | Paragraphs with biblio style | Style from template |

### 2. Implement IsoDoc::DocxAdapter

Create `lib/isodoc/docx_adapter.rb` in isodoc:

```ruby
module IsoDoc
  class DocxAdapter
    def initialize(template_path:, style_mapping: {})
      @template = Uniword::DocxPackage.from_file(template_path)
      @style_mapping = style_mapping
    end

    def convert(xml, output_path)
      doc = Uniword::Builder::DocumentBuilder.new
      load_template_styles(doc)
      walk(xml, doc)
      doc.save(output_path)
    end

    private

    def load_template_styles(doc)
      # Apply styles/numbering/fonts/theme/settings from template
    end

    def walk(xml, builder)
      xml.children.each { |child| visit(child, builder) }
    end

    def visit(element, builder)
      case element.name
      when "p"        then visit_paragraph(element, builder)
      when "table"    then visit_table(element, builder)
      when "ol", "ul" then visit_list(element, builder)
      # ...
      end
    end
  end
end
```

### 3. Implement element visitors

Each visitor maps XML attributes + content to builder calls:

```ruby
def visit_paragraph(element, builder)
  para = builder.paragraph do |p|
    p.style = style_for(element)
    p.align = alignment_for(element) if element["align"]
    element.children.each { |child| visit_inline(child, p) }
  end
end

def visit_inline(element, para)
  case element.name
  when "strong"  then para << bold_run(element.text)
  when "em"      then para << italic_run(element.text)
  when "sub"     then para << subscript_run(element.text)
  when "sup"     then para << superscript_run(element.text)
  when "a"       then para << hyperlink(element["href"], element.text)
  when "image"   then para << image_run(element)
  when "stem"    then para << math_run(element)
  when "br"      then para << break_run
  when "fn"      then para << footnote_run(element)
  else
    para << element.text if element.text?
  end
end
```

### 4. Handle sections and headers/footers

Sections from the presentation XML map to `SectionBuilder`:

```ruby
def visit_section(element, builder)
  builder.section(type: "nextPage") do |sec|
    sec.header(type: "default") { |h| h << header_content(element) }
    sec.footer(type: "default") { |f| f << page_number_field }
    sec.page_size(width: ..., height: ...)
    sec.margins(top: ..., bottom: ..., left: ..., right: ...)
  end
end
```

### 5. Wire into isodoc's output pipeline

In `isodoc/lib/isodoc/word_function/postprocess.rb`, add a branch:

```ruby
def toWord(result, filename, dir, header)
  if output_format == :docx
    toDocx(result, filename)
  else
    Html2Doc.new(...).process(result)
  end
end

def toDocx(xml, filename)
  adapter = IsoDoc::DocxAdapter.new(
    template_path: docx_template_path,
    style_mapping: docx_style_mapping
  )
  adapter.convert(xml, "#{filename}.docx")
end
```

### 6. ISO-specific overrides in metanorma-iso

Override `docx_template_path` and `docx_style_mapping` in metanorma-iso:

```ruby
module IsoDoc::Iso
  class WordConvert < IsoDoc::WordConvert
    def docx_template_path
      IsoDoc::Iso.default_docx_template
    end

    def docx_style_mapping
      @docx_style_mapping ||= YAML.load_file(
        File.expand_path("../../data/style_mapping.yml", __dir__)
      )
    end
  end
end
```

## Acceptance Criteria

- [ ] DocxAdapter converts basic isodoc presentation XML to valid DOCX
- [ ] Paragraphs, headings, bold, italic, links work
- [ ] Tables with merged cells work
- [ ] Ordered/unordered lists work
- [ ] Footnotes and endnotes work
- [ ] Images embed correctly
- [ ] Math (OMML) passes through
- [ ] Sections with headers/footers work
- [ ] Output passes DOC-100..DOC-109 validation
- [ ] ISO-specific styles are applied from template

## Open Questions

- Should the adapter consume isodoc's presentation XML or the raw Metanorma XML? (Recommendation: presentation XML, since isodoc already processes it)
- How to handle multi-section documents (different first page, odd/even headers)?
- How to handle cross-references (bookmarks, hyperlinks between sections)?
