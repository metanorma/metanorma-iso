# 07 — HTML renderer: `Metanorma::Iso::Sts::HtmlRenderer::Ruby`

## Why
OIML has a typed-model → HTML renderer that walks an `Sts::NisoSts::Standard`
tree through a dispatch table and emits HTML via Liquid templates — no XSLT,
no Nokogiri. The renderer is OCP-friendly: new element types are a new
dispatch entry, not a code branch.

ISO has nothing equivalent. The user has explicitly asked for STS HTML
output to be demonstrated. Port the renderer and adapt the dispatch table
from NisoSts types to **IsoSts** types (ISO's metadata block is `<iso-meta>`
with `IsoMeta`, `TitleWrap`, `TitleIntro/Main/Compl/Full`,
`DocumentIdentification`, `StandardIdentification`, `StdRef`, `DocRef`,
`ReleaseDate`, `CommRef`, `Secretariat`, `Permissions`,
`CopyrightStatement/Year/Holder`, `Ics`, etc.).

## Architecture

```
HtmlRenderer
  autoload :Ruby
  module_function def render(model_or_xml, **) = Ruby.new.render(...)

HtmlRenderer::Ruby
  - DISPATCH      { class_name => handler_symbol }
  - INLINE_TAGS   { sts_class => html_tag }
  - render(model_or_xml, full_document: true)
      ├── coerce_model        # XML string → Sts::IsoSts::Standard
      ├── render_node         # dispatch by class name
      └── assemble_document   # fragment → full page via templates
```

## Plan
1. Create `lib/metanorma/iso/sts/html_renderer.rb` — parent namespace,
   autoloads `Ruby` and exposes `.render` module method (mirrors OIML).
2. Create `lib/metanorma/iso/sts/html_renderer/ruby.rb` — the renderer
   class. Adapt OIML's `DISPATCH` for IsoSts:
   - Replace `MetadataStd`/`MetadataIso` with `IsoMeta`/`RegMeta`/`NatMeta`.
   - Add ISO-specific handlers: `DocIdent`, `StdIdent`, `StdRef`, `DocRef`,
     `ReleaseDate`, `CommRef`, `Secretariat`, `Ics`, `Sdo`, `Originator`,
     `DocType`, `DocNumber`, `PartNumber`, `ProjId`, `ReleaseVersion`,
     `Edition`, `Language`, `TitleWrap`, `TitleIntro`, `TitleMain`,
     `TitleCompl`, `TitleFull`, `CopyrightStatement`, `CopyrightYear`,
     `CopyrightHolder`, `Permissions`.
   - Keep shared handlers: `Section`, `Paragraph`, `List`, `ListItem`,
     `TableWrap`, `Table`, `Thead`, `Tbody`, `Tr`, `Td`, `Th`, `Figure`,
     `Caption`, `Graphic`, `DisplayFormula`, `InlineFormula`, `Preformat`,
     `NonNormativeNote`, `NonNormativeExample`, `DispQuote`,
     `ReferenceList`, `Reference`, `MixedCitation`, `ElementCitation`,
     `Fn`, `Xref`, `ExtLink`, `Break`, `Label`, `Title`, `TermSection`,
     `Term`, `DefItem`, `DefList`.
3. The `meta_info` extractor reads ISO-specific paths (`iso-meta/title-wrap/
   title-main`, `iso-meta/doc-ident/sdo`, `iso-meta/std-ident/originator`,
   etc.).
4. Use a text-based ISO wordmark (`<span class="brand-wordmark">ISO</span>`)
   rather than shipping ISO's logo (licensing).
5. Templates and assets are TODOs #08 and #09.

## Acceptance
- `Metanorma::Iso::Sts.render_html(model)` returns a String starting with
  `<!DOCTYPE html>`.
- Dispatch table is constant-keyed (no `case/when` chain).
- No Nokogiri (parse the STS XML through sts-ruby's `from_xml`).
- No `send` to private methods, no `instance_variable_set/get`, no
  `respond_to?` (use `is_a?` or `class.method_defined?`).
