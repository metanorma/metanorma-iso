# 13 - Transformer: Body (Sections)

## Mapping: Metanorma XML sections → Sts::IsoSts::Body

The body contains the main normative content in a specific ordering mandated by ISO/IEC Directives.

## Body Construction Order (from mn2xml.xsl `insertBody`)

```
<body>
  <!-- 1. Introduction (from sections/clause[@type='intro']) -->
  <sec sec-type="intro">...</sec>

  <!-- 2. Scope (from sections/clause[@type='scope']) -->
  <sec sec-type="scope">...</sec>

  <!-- 3. Normative References (from bibliography/references[@normative='true']) -->
  <ref-list content-type="norm-refs">...</ref-list>

  <!-- 4. Terms and Definitions (from sections/terms, sections/definitions) -->
  <term-sec>...</term-sec>
  <!-- or nested in sec if vocabulary document -->

  <!-- 5. Remaining clauses (sections/clause, excluding intro/scope) -->
  <sec>...</sec>
  <sec>...</sec>
</body>
```

## Section Transformer: IsoClauseSection → Sts::IsoSts::Sec

### Attribute Mapping

```
IsoClauseSection.id → Sec.id (via IdGenerator)
IsoClauseSection.type → Sec.sec_type (if recognized)
IsoClauseSection.number → Sec.label content
IsoClauseSection.title → Sec.title
IsoClauseSection.obligation → (handled in sec-type)
```

### sec-type Values

| IsoClauseSection.type | Sec.sec_type |
|-----------------------|-------------|
| `intro` | `intro` |
| `scope` | `scope` |
| `overview` | `scope` |
| (nil/other) | (nil) |

### Content Mapping

`IsoClauseSection` contains collections of block elements. Each block type maps to its own transformer:

```
clause.paragraphs       → Sec.paragraph (via ParagraphTransformer)
clause.unordered_lists  → Sec.list (via ListTransformer)
clause.ordered_lists    → Sec.list (via ListTransformer)
clause.tables           → Sec.table_wrap (via TableTransformer)
clause.figures          → Sec.fig (via FigureTransformer)
clause.formulas         → Sec.disp_formula (via FormulaTransformer)
clause.examples         → Sec.non_normative_example (via ExampleTransformer)
clause.notes            → Sec.non_normative_note (via NoteTransformer)
clause.sourcecode       → Sec.preformat (via SourcecodeTransformer)
clause.definitions      → Sec.def_list (via DefListTransformer)
clause.quotes           → Sec.disp_quote (via QuoteTransformer)
clause.clause           → Sec.sec (recursive, via SectionTransformer)
```

### Critical: Element Ordering

`IsoClauseSection` uses `ordered` mode (or provides `each_mixed_content`) to preserve document order. The transformer must iterate blocks in document order, not by type.

```ruby
class SectionTransformer < Base
  def transform(clause)
    sec = Sts::IsoSts::Sec.new
    sec.id = id_for(clause)
    sec.sec_type = sec_type_for(clause)
    sec.label = label_for(clause)
    sec.title = title_for(clause)

    # Iterate in document order
    clause.each_mixed_content do |element|
      case element
      when Metanorma::Document::Components::Paragraphs::ParagraphBlock
        sec.paragraph << ParagraphTransformer.new(@context).transform(element)
      when Metanorma::Document::Components::Lists::UnorderedList,
           Metanorma::Document::Components::Lists::OrderedList
        sec.list << ListTransformer.new(@context).transform(element)
      # ... etc
      end
    end

    sec
  end
end
```

## Terms Section Transformer: IsoTermsSection → Sts::IsoSts::TermSec

Terms are the most complex transformation. Each `term` element maps to a `term-sec` containing a `tbx:termEntry`.

See `14-transformer-terms.md` for details.

## Normative References in Body

Normative references are placed in the body as a `ref-list`:

```xml
<ref-list content-type="norm-refs">
  <title>Normative references</title>
  <ref id="sec_biblref_1">
    <label>[1]</label>
    <mixed-citation>ISO 8601-1:2019, <em>Date and time</em></mixed-citation>
    <std><std-ref>ISO 8601-1:2019</std-ref></std>
  </ref>
</ref-list>
```

The first normative reference also includes boilerplate text about dated/undated references.
