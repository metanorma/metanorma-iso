# 06 — Public API on `Metanorma::Iso::Sts`

## Why
Today, `Metanorma::Iso::Sts` is essentially just a feature flag
(`enabled?`/`enabled=`). The actual transformer entry point lives at
`Metanorma::Iso::Sts::Transformer.transform(source)` which requires the
caller to already have a typed root in hand. That makes ad-hoc conversion
("give me the STS XML for this file") painful — you have to know about
`Metanorma::IsoDocument::Root.from_xml`, the `Context` constructor, the
`DocumentTransformer` class, and the `NbspProcessor` post-step.

OIML shows the right shape:

```ruby
Metanorma::Oiml::Sts.convert(xml_string)         # → STS XML string
Metanorma::Oiml::Sts.convert_to_model(xml_string) # → Sts::NisoSts::Standard
Metanorma::Oiml::Sts.render_html(model_or_xml)   # → HTML string (new, see #07)
```

ISO should match.

## Plan
1. In `lib/metanorma/iso/sts.rb`, add module methods:
   ```ruby
   def self.convert(input)
     model_to_xml(convert_to_model(input))
   end

   def self.convert_to_model(input)
     source = Transformer::SourceDocument.parse(input)
     context = Transformer::Context.new(source)
     Transformer::DocumentTransformer.new(context).transform(source)
   end

   def self.render_html(model_or_xml, **opts)
     HtmlRenderer.render(model_or_xml, **opts)
   end
   ```
2. `model_to_xml(model)` does the framework serialization +
   `NbspProcessor` post-process + namespace/lang fix-ups (port OIML's
   `inject_namespaces` / `inject_processing_meta` / `fix_lang_attribute`).
3. Keep the `enabled?`/`enabled=` flag for backward compatibility with
   the existing Processor wiring — it stays a separate concept (whether
   the `:isosts` output format uses the native transformer or mnconvert).

## Acceptance
- `Metanorma::Iso::Sts.convert(File.read("spec/examples/rice.xml"))`
  returns an ISO-STS XML string containing `<standard>` root.
- `Metanorma::Iso::Sts.convert_to_model(...)` returns a
  `Sts::IsoSts::Standard` instance.
- The existing `:isosts` QA gate is unaffected.
- Specs in TODO #11 cover both methods.
