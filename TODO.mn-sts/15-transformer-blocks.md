# 15 - Transformer: Block Elements

Block-level elements within sections: paragraphs, lists, tables, figures, formulas, notes, examples, sourcecode, quotes.

## Paragraph Transformer

### Source → Target
```
Metanorma::Document::Components::Paragraphs::ParagraphBlock → Sts::IsoSts::Paragraph
```

### Mapping
```
paragraph.id              → Paragraph.id
paragraph.content (text)  → Paragraph.content (mixed content)
paragraph.bold            → Paragraph.bold (via InlineTransformer)
paragraph.italic          → Paragraph.italic
paragraph.sub             → Paragraph.sub
paragraph.sup             → Paragraph.sup
paragraph.xref            → Paragraph.xref
paragraph.eref            → Paragraph.std
paragraph.stem            → Paragraph.inline_formula or Paragraph.math
paragraph.fn              → Paragraph.fn (or footnote wrapper for dedup)
paragraph.image           → Paragraph.graphic
paragraph.break           → Paragraph.break
```

### Mixed Content Handling
Paragraph text contains interleaved text and inline elements. The transformer must iterate the mixed content in order:
```ruby
class ParagraphTransformer < Base
  def transform(source)
    p = Sts::IsoSts::Paragraph.new
    p.id = id_for(source) if source.id && !source.id.start_with?("_")
    p.content_type = source.type if source.type

    # Mixed content iteration
    source.each_mixed_content do |node|
      case node
      when String
        p.content << node
      when Metanorma::Document::Components::Inline::StrongElement
        p.bold = InlineTransformer.new(@context).transform_bold(node)
      # ... etc
      end
    end

    p
  end
end
```

## List Transformer

### Source → Target
```
Components::Lists::UnorderedList → Sts::IsoSts::List
Components::Lists::OrderedList   → Sts::IsoSts::List
```

### Mapping
```
list.id → List.id
ul      → List[@list-type='bullet']
ol      → List[@list-type='order'] (or 'alpha-lower', 'roman-lower', etc. based on type)
li      → ListItem
  li.p  → ListItem.paragraph
  li.ul → ListItem.list (nested)
  li.ol → ListItem.list (nested)
```

### Ordered List Type Mapping

| MN ol/@type | STS list/@list-type |
|-------------|---------------------|
| `arabic` | `order` |
| `loweralpha` | `alpha-lower` |
| `upperalpha` | `alpha-upper` |
| `lowerroman` | `roman-lower` |
| `upperroman` | `roman-upper` |

## Definition List Transformer

### Source → Target
```
Components::Lists::DefinitionList → Sts::IsoSts::DefList
Components::Lists::DefinitionItem → Sts::IsoSts::DefItem
```

### Mapping
```
dl.id       → DefList.id
dt          → DefItem.term
dd          → DefItem.def
dd/p        → DefItem.def.paragraph
dd/ul       → DefItem.def.list
```

## Table Transformer

### Source → Target
```
Components::Tables::TableBlock → Sts::IsoSts::TableWrap (containing Sts::IsoSts::Table)
```

### Mapping
```
table.id          → TableWrap.id
table.number      → TableWrap.label content
table.title       → TableWrap.caption.title
table             → TableWrap.table
  thead           → Table.thead
  tbody           → Table.tbody
  tfoot           → Table.tfoot
  tr              → Tr
  th              → Th (with @align, @valign, @colspan, @rowspan)
  td              → Td (same attributes)
  colgroup        → Colgroup
  col             → Col
table.notes       → TableWrap.table_wrap_foot.non_normative_note
table.key         → TableWrap.table_wrap_foot (as key/list)
table.fn          → Collected into fn-group
```

### Table ID Scheme
```
Numbered tables: TableWrap.id = "tab_{section}" (e.g., "tab_1")
Unnumbered:      TableWrap.id = "tab_a" (sequential letter)
```

### Table Cell Content
Cell content (th/td) uses mixed content — same inline transformers as paragraphs.

## Figure Transformer

### Source → Target
```
Components::AncillaryBlocks::FigureBlock → Sts::IsoSts::Fig
```

### Mapping
```
figure.id     → Fig.id
figure.number → Fig.label content
figure.title  → Fig.caption (via CaptionTransformer)
figure.image  → Fig.graphic (via GraphicTransformer)
  image.src   → graphic/@xlink:href
  image.alt   → graphic/alt-text
figure.note   → Fig.non_normative_note
figure.key    → Fig (as key array)
```

### Figure ID Scheme
```
Numbered: Fig.id = "fig_{section}" (e.g., "fig_1")
Multi-graphic: graphic/@id = "fig_{section}.{n}" for each graphic
```

## Formula Transformer

### Source → Target
```
Components::Blocks::StandardFormulaBlock → Sts::IsoSts::DispFormula
```

### Mapping
```
formula.id     → DispFormula.id
formula.number → DispFormula.label content
formula.stem   → DispFormula mml:math content
formula.note   → DispFormula.non_normative_note (if any)
formula.key    → array (as key table)
```

### Formula ID Scheme
```
Numbered: DispFormula.id = "formula_{section}" (e.g., "formula_(1)" → "formula_1")
Unnumbered: no id
```

## Note / Example Transformers

### Note
```
Components::Blocks::StandardNoteBlock → Sts::IsoSts::NonNormativeNote
  note.p → NonNormativeNote.paragraph
```

### Example
```
Components::Blocks::StandardExampleBlock → Sts::IsoSts::NonNormativeExample
  example.p → NonNormativeExample.paragraph
  example.* → (same block transforms as in sections)
```

## Sourcecode Transformer

```
Components::Blocks::StandardSourcecodeBlock → Sts::IsoSts::Preformat
  sourcecode.content → Preformat.content
  sourcecode.lang    → Preformat.@preformat-type
```

## Quote Transformer

```
Components::Blocks::StandardQuoteBlock → Sts::NisoSts::DispQuote
  quote.p    → DispQuote.paragraph
  quote.source → DispQuote.attrib
```
