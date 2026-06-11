# 01 - Overview: Re-implement MN→ISO NISO STS Conversion in Ruby

## Goal

Replace the Java XSLT-based `mnconvert` Metanorma XML → ISO NISO STS conversion with a pure-Ruby pipeline built on:
- **Source model**: `metanorma-document` (`Metanorma::IsoDocument::Root`) — Lutaml::Model classes
- **Target model**: `sts-ruby` (`Sts::IsoSts::Standard`) — Lutaml::Model classes
- **Transformation**: A new `Transformer` class hierarchy that maps between them

## Two Phases

### Phase 1: Round-trip ISO NISO STS XML in sts-ruby
The sts-ruby model must be able to parse and re-serialize real-world ISO NISO STS files without data loss. This validates the target model is complete before building the transformer.

**Reference files**: `mn-samples-iso-private/reference-docs/` (~16 documents including ISO 8601-1, ISO 10303 parts, ISO 34000, etc.)

**Success criterion**: Every `.xml` in `reference-docs/` round-trips: `Sts::IsoSts::Standard.from_xml(xml).to_xml` produces XML-equivalent output.

### Phase 2: Build the Transformer
Create a `Metanorma::Iso::Sts::Transformer` that converts `IsoDocument::Root` → `Sts::IsoSts::Standard`.

**Success criterion**: For each sample document that has both a Metanorma XML source and a reference STS XML, the transformer output is XML-equivalent to the reference.

## Design Principles

- **OOP**: Each transformation concern is a focused class
- **MECE**: Transformers are mutually exclusive (no overlap) and collectively exhaustive (no gaps)
- **Open-Closed**: New element types are handled by adding a new transformer subclass, not modifying existing ones
- **DRY**: Shared logic in base classes; no copy-paste mapping code

## File Locations

| Component | Location |
|-----------|----------|
| Source model | `../metanorma-document/lib/metanorma/iso_document/` |
| Target model | `../sts-ruby/lib/sts/iso_sts/` |
| Reference XSLT | `../mnconvert/src/main/resources/mn2sts.xsl` + `mn2xml.xsl` |
| Reference STS XML | `../mn-samples-iso-private/reference-docs/` |
| Transformer code | New: `lib/metanorma/iso/sts/` (in this repo) |
