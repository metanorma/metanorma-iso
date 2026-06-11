# 18 - Transformer: Footnotes, ID Generation, NBSP Processing

## Footnote Processing

Footnote handling is the most intricate post-processing step in the mnconvert XSLT. Footnotes must be:
1. **Deduplicated** (same text → same footnote, shared across document)
2. **Numbered** sequentially
3. **Split** by context (text footnotes, table footnotes, figure footnotes)
4. **Collected** into `fn-group` in back matter (for text footnotes)

### Footnote Categories

| Category | Location | ID Pattern | Label Format |
|----------|----------|------------|-------------|
| Text footnotes | body text | `fn_{n}` | `<sup>n)</sup>` |
| Table footnotes | inside table-wrap | `table-fn_{table}.{n}` | `a)`, `b)`, ... |
| Figure footnotes | inside fig | `figure-fn_{fig}.{n}` | `a)`, `b)`, ... |

### Deduplication Algorithm

1. Collect all footnotes in text (not inside table-wrap or fig)
2. Group by normalized text content
3. First occurrence: keep `fn` element with new ID + `xref` pointing to it
4. Subsequent occurrences: only emit `xref` (reuse existing `fn`)

```ruby
class FootnoteCollector
  def initialize
    @footnotes = {}  # text => { id:, number: }
    @counter = 0
  end

  def register(footnote_text)
    normalized = footnote_text.strip
    if @footnotes.key?(normalized)
      @footnotes[normalized]
    else
      @counter += 1
      entry = { id: "fn_#{@counter}", number: @counter }
      @footnotes[normalized] = entry
      entry
    end
  end

  def fn_group
    return nil if @footnotes.empty?
    # Build fn-group from all unique footnotes
    group = Sts::IsoSts::FnGroup.new
    @footnotes.each do |text, entry|
      fn = Sts::IsoSts::Fn.new(id: entry[:id])
      fn.label = Sts::IsoSts::Label.new(content: "<sup>#{entry[:number]})</sup>")
      fn.paragraph = Sts::IsoSts::Paragraph.new(content: text)
      group.fn << fn
    end
    group
  end
end
```

### Table/Figure Footnotes

Table and figure footnotes are scoped to their container:
- Collected per table-wrap/fig
- Not deduplicated with text footnotes
- Remain inside the table-wrap/fig, not in fn-group

## ID Generation

### ISO ID Scheme (from mn2sts.xsl)

IDs follow ISO's naming convention for elements:

| Element | ID Pattern | Example |
|---------|-----------|---------|
| foreword sec | `sec_foreword` | `sec_foreword` |
| introduction sec | `sec_intro` or `sec_0` | `sec_intro` |
| scope sec | `sec_scope` | `sec_scope` |
| body sec | `sec_{section}` | `sec_3`, `sec_3.1` |
| annex | `sec_{letter}` | `sec_A` |
| annex subsec | `sec_{letter}.{n}` | `sec_A.1` |
| term-sec | `sec_{section}` | `sec_3.1` |
| termEntry | `term_{section}` | `term_3.1` |
| numbered table | `tab_{section}` | `tab_1`, `tab_A.1` |
| unnumbered table | `tab_{letter}` | `tab_a` |
| numbered figure | `fig_{section}` | `fig_1` |
| numbered formula | `formula_{section}` | `formula_1` |
| bibliography ref | `biblref_{section}` | `biblref_1` |
| index sec | `sec_index` | `sec_index` |
| text footnote | `fn_{n}` | `fn_1` |
| table footnote | `table-fn_{table}.{n}` | `table-fn_1.1` |
| figure footnote | `figure-fn_{fig}.{n}` | `figure-fn_1.1` |

### Section Numbering

Section numbers come from:
1. For presentation XML: `@displayorder` or explicit section numbering
2. For semantic XML: Must be calculated from element position in document

### ID Remapping

All cross-references (`xref/@rid`, `std/@bibitemid`) must be remapped from Metanorma IDs to STS IDs using the same IdGenerator.

```ruby
class IdGenerator
  def initialize(context)
    @context = context
    @id_map = {}  # source_id → sts_id
  end

  def register(source_id, sts_id)
    @id_map[source_id] = sts_id
  end

  def remap(source_id)
    @id_map[source_id] || source_id  # fallback to original
  end

  def id_for(element)
    # Generate STS ID based on element type and section number
  end
end
```

## Non-Breaking Space (NBSP) Processing

ISO STS requires non-breaking spaces (`&#xA0;`) in specific patterns. This is a text post-processing step applied to all text content outside of metadata sections.

### NBSP Rules (from mn2sts.xsl)

| Pattern | Replacement | Example |
|---------|-------------|---------|
| number + SI unit name | `1&#xA0;meter` | `1 meter` |
| number + SI unit symbol | `1&#xA0;s` | `1 s` |
| Part + digit | `Part&#xA0;1` | `Part 1` |
| digit + `%` | `1&#xA0;%` | `1 %` |
| ISO + digit | `ISO&#xA0;8601` | `ISO 8601` |
| ISO/TC + digit | `ISO/TC&#xA0;154` | `ISO/TC 154` |
| NOTE + digit | `NOTE&#xA0;1` | `NOTE 1` |
| Note + digit + "to entry" | `Note&#xA0;1&#xA0;to entry` | `Note 1 to entry` |
| Table/Figure/Clause + number | `Table&#xA0;1` | `Table 1` |
| Formula + number | `Formula&#xA0;(1)` | `Formula (1)` |
| SC + digit | `SC&#xA0;1` | `SC 1` |
| Annex + letter | `Annex&#xA0;A` | `Annex A` |
| `— ` before capital letter | `&#xA0;— A` | `— A` |
| digit + math sign + digit | `1&#xA0;±&#xA0;1` | `1 ± 1` |

### Implementation

```ruby
class NbspProcessor
  RULES = [
    [/(\d) (second|meter|kilogram|ampere|kelvin|mole|candela)/, '\1 \2'],
    [/(\d) ((s|m|kg|A|K|mol|cd)( |\.|\)|$))/, '\1 \2'],
    [/(Part) (\d)/, '\1 \2'],
    [/(\d) (%)/, '\1 \2'],
    [/(ISO) (\d)/, '\1 \2'],
    [/(ISO\/TC) (\d)/, '\1 \2'],
    [/(NOTE) (\d)/, '\1 \2'],
    [/(Note)\s(\d)\s(to entry)/, '\1 \2 \3'],
    [/(Table|Figure|Clause|Volume) (([A-Za-z]\.)?\d)/, '\1 \2'],
    [/(Formula) (\(([A-Za-z]\.)?\d)/, '\1 \2'],
    [/(SC) (\d)/, '\1 \2'],
    [/(Annex) ([A-Za-z](\.\d+)*( |\.|\)|$))/, '\1 \2'],
    [/ (— [A-Z])/, ' \1'],
    [/(\d)\s([+\-\/\*≠<>≤≥±×÷∙mod%^])\s(\d)/, '\1 \2 \3'],
  ].freeze

  def self.process(text)
    RULES.reduce(text) do |t, (pattern, replacement)|
      t.gsub(pattern, replacement.gsub(' ', " "))
    end
  end
end
```
