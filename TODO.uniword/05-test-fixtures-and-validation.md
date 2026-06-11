# 05: Test Fixtures & Validation

## Summary

Create a test infrastructure for validating DOCX output from metanorma-iso using real mn-samples-iso content, with Uniword's validation rules as acceptance criteria.

## Motivation

Currently, html2doc uses `rice.html`/`rice.doc`/`rice.docx` as test fixtures — these are old, domain-specific, and don't represent real ISO document output. We need fixtures from real metanorma-iso output and automated validation against structural integrity rules.

## Prerequisites

- 01: Architecture & Dependency Setup
- Uniword >= 1.0.6 (validation rules: DOC-100..DOC-109)

## Tasks

### 1. Download reference documents from mn-samples-iso

Visit https://metanorma.github.io/mn-samples-iso/ and download:
- An ISO International Standard (e.g., ISO 10303-1 or similar)
- Its Word output (MHT .doc format)
- Manually save a DOCX version from Word for comparison

Place in `spec/fixtures/`:
```
spec/fixtures/
  iso-reference.doc      # MHT from mn-samples-iso
  iso-reference.docx     # DOCX saved from Word
  iso-reference.xml      # Presentation XML from metanorma-iso
```

### 2. Set up DOCX validation in metanorma-iso specs

Create a shared example for DOCX validation:

```ruby
# spec/support/docx_validation.rb
RSpec.shared_examples "a valid DOCX" do |path|
  it "passes DOC-100..DOC-109 validation" do
    ctx = Uniword::Validation::Rules::DocumentContext.new(path)
    errors = Uniword::Validation::Rules::Registry.all.flat_map do |rule|
      rule.applicable?(ctx) ? rule.check(ctx) : []
    end.select { |i| i.severity == "error" && i.code.to_s.match?(/^DOC-10[0-9]$/) }
    ctx.close

    expect(errors).to be_empty,
      "DOCX validation errors:\n#{errors.map { |e| "  #{e.code}: #{e.message}" }.join("\n")}"
  end
end
```

### 3. Write integration tests for the DOCX adapter

```ruby
# spec/isodoc/docx_adapter_spec.rb
RSpec.describe IsoDoc::DocxAdapter do
  let(:template) { IsoDoc::Iso.default_docx_template }
  let(:adapter) { described_class.new(template_path: template) }

  it "converts a simple paragraph" do
    xml = Nokogiri::XML("<p>Hello World</p>")
    adapter.convert(xml, "tmp/test.docx")
    expect("tmp/test.docx").to be_a_valid_docx
  end

  it "converts headings with correct styles" do
    # ...
  end

  it "converts tables" do
    # ...
  end

  it "converts footnotes" do
    # ...
  end

  it "matches reference DOCX output" do
    # Compare against iso-reference.docx
  end
end
```

### 4. Run Uniword round-trip validation on template

```ruby
it "ISO template passes round-trip validation" do
  pkg = Uniword::DocxPackage.from_file(IsoDoc::Iso.default_docx_template)
  pkg.to_file("tmp/iso-template-rt.docx")
  expect("tmp/iso-template-rt.docx").to be_a_valid_docx
end
```

### 5. Content comparison tests

For the full integration test, compare generated DOCX against reference:

```ruby
it "produces equivalent content to reference DOCX" do
  # Generate DOCX from presentation XML
  adapter.convert(presentation_xml, "tmp/generated.docx")

  # Load both and compare paragraphs
  ref = Uniword::DocumentFactory.from_file("spec/fixtures/iso-reference.docx")
  gen = Uniword::DocumentFactory.from_file("tmp/generated.docx")

  expect(gen.paragraphs.map(&:text_content)).to eq(ref.paragraphs.map(&:text_content))
end
```

## Acceptance Criteria

- [ ] Reference fixtures from mn-samples-iso downloaded and committed
- [ ] DOCX validation shared examples available in spec suite
- [ ] ISO template passes round-trip validation
- [ ] Basic adapter tests pass (paragraphs, headings, tables, lists)
- [ ] Content comparison test against reference DOCX

## Open Questions

- Which specific document from mn-samples-iso should be the reference?
- How strict should content comparison be? (exact match vs structural equivalence)
