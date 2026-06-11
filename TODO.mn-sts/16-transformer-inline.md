# 16 - Transformer: Inline Elements

Inline elements appear within paragraphs, table cells, titles, and other mixed-content contexts. They must be processed in document order (interleaved with text nodes).

## Inline Element Map

| Metanorma Element | STS Element | Notes |
|-------------------|-------------|-------|
| `<strong>` | `<bold>` | Direct mapping |
| `<em>` | `<italic>` | Direct mapping, except when part of entailedTerm pattern |
| `<sub>` | `<sub>` | Direct mapping |
| `<sup>` | `<sup>` | Direct mapping |
| `<tt>` / `<monospace>` | `<monospace>` | Direct mapping |
| `<smallcap>` | `<sc>` | Small caps |
| `<underline>` | `<underline>` | Direct mapping |
| `<strike>` | `<strike>` | Direct mapping |
| `<keyword>` | `<styled-content style-type="keyword">` | |
| `<xref target="...">` | `<xref rid="..." ref-type="sec">` | Cross-references |
| `<eref bibitemid="...">` | `<std>` or `<std-ref>` | Bibliographic references |
| `<concept>` | `<tbx:entailedTerm>` | Only inside term entries |
| `<stem>` (inline) | `<inline-formula>` | Inline math |
| `<fn>` | `<fn>` / `<xref ref-type="fn">` | Footnotes (see 18-transformer-footnotes.md) |
| `<image>` (inline) | `<graphic>` | Inline graphics |
| `<br>` | `<break/>` | Line break |
| `<bookmark>` | `<target>` | Anchor point |
| `<link target="...">` | `<ext-link xlink:href="...">` | External links |
| `<span>` | `<styled-content>` | Generic styled content |

## InlineTransformer (Dispatcher)

```ruby
class InlineTransformer < Base
  def transform_inline(node)
    case node
    when Metanorma::Document::Components::Inline::StrongElement
      transform_bold(node)
    when Metanorma::Document::Components::Inline::EmphasisElement
      transform_italic(node)
    when Metanorma::Document::Components::Inline::SubElement
      Sts::NisoSts::Sub.new(content: node.content)
    when Metanorma::Document::Components::Inline::SupElement
      Sts::NisoSts::Sup.new(content: node.content)
    when Metanorma::Document::Components::Inline::MonospaceElement
      Sts::NisoSts::Monospace.new(content: node.content)
    when Metanorma::Document::Components::Inline::CrossRefElement
      CrossRefTransformer.new(@context).transform(node)
    when Metanorma::Document::Components::Inline::BibRefElement
      BibRefTransformer.new(@context).transform(node)
    when Metanorma::Document::Components::Inline::StemElement
      FormulaTransformer.new(@context).transform_inline(node)
    when String
      node
    else
      # Unknown inline element — pass through as text
      node.to_s
    end
  end

  def transform_bold(node)
    Sts::IsoSts::Bold.new(
      # recursively transform children (bold can contain italic, xref, etc.)
    )
  end

  def transform_italic(node)
    Sts::IsoSts::Italic.new(
      # recursively transform children
    )
  end
end
```

## Cross-Reference Transformer

### xref → xref

```
xref/@target → xref/@rid
              → xref/@ref-type based on target element type:
                - term → "term-sec"
                - sec → "sec"
                - table → "table"
                - figure → "fig"
                - formula → "disp-formula"
                - fn → "fn" or "table-fn"
                - note → "other"
                - bibitem → "bibr"
xref/text() → xref content (label text)
```

### ID Remapping

The `rid` attribute must use the STS-generated ID, not the original Metanorma ID:
```ruby
xref.rid = @context.id_generator.remap_id(original_target)
```

## Bibliographic Reference Transformer

### eref → std / std-ref

```
<eref bibitemid="ISO8601" type="normative">
  <localityStack><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></localityStack>
</eref>

→

<std std-id="ISO 8601-1:2019" type="dated">
  <std-ref>ISO 8601-1:2019, 3.1</std-ref>
</std>
```

### Mapping Rules
```
eref/@bibitemid → look up bibitem, extract formatted reference
eref/@type → std/@type ("dated" or "undated")
localityStack → appended to std-ref text after comma
renderterm → std-ref text content (if present)
```

### Inside term entries (tbx:source)
For ISO: `<tbx:source>` contains plain text only (no nested `<std>`).
For IEC: `<tbx:source>` can contain `<std>`.

## Concept → tbx:entailedTerm

Only used inside term entries. See `14-transformer-terms.md` for details.

Two patterns:
1. `<em>term</em> (<xref target="term_X">N</xref>)` → `<tbx:entailedTerm target="term_X">term (N)</tbx:entailedTerm>`
2. `<concept><eref bibitemid="..."/><renderterm>...</renderterm></concept>` → `<tbx:entailedTerm xtarget="...">renderterm</tbx:entailedTerm>`
