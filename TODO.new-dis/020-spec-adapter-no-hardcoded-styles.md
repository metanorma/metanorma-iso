# 020 — Spec: Adapter purity (no hardcoded style strings)

## Goal

Lock down the architectural rule that adapter (and any renderer under
`lib/isodoc/iso/docx/`) holds **no styleId string literals** and **no
`||` style fallback chains**. This prevents regression after TODO 007
and TODO 008 land.

## What the spec asserts

Static scan of every `.rb` file under `lib/isodoc/iso/docx/`:

1. **No styleId literals**: no quoted string matching a known styleId
   from `styles.yml` (`"ANNEX"`, `"Heading1"`, `"Note"`, `"Warningtext"`,
   etc.). Permits: the YAML loader itself (`docx_style_mapping.rb`),
   which reads styleIds from YAML, not literals.
2. **No fallback chains**: no `||` operator appearing in a method whose
   return value is later used as a style argument. Practical proxy: no
   `paragraph_style(...) || ...` or `paragraph_style_or_nil` callers in
   renderer code.
3. **No `"Heading#"` interpolation**: regex `["']Heading#\{[^}]+\}["']`
   must not match.
4. **No `"TOC#"` interpolation**: regex `["']TOC#\{[^}]+\}["']` must not
   match.
5. **No `DefinitionListRenderer` building plain paragraphs for `<dl>`**
   (TODO 011 closes that).

## File layout

```
spec/isodoc/iso/docx/
  adapter_purity_spec.rb
  support/
    source_scan.rb
```

## Spec sketch

```ruby
require "spec_helper"
require "isodoc/iso/docx"

module IsoDoc
  module Iso
    module Docx
      RSpec.describe "Adapter purity" do
        let(:library) { StyleLibrary.load_default }
        let(:all_style_ids) { library.all_style_ids }
        let(:source_files) do
          Pathname("lib/isodoc/iso/docx/").glob("**/*.rb")
        end
        let(:whitelist_files) do
          %w[
            docx_style_mapping.rb
            style_library.rb
            style_mapping_validator.rb
            template_provenance.rb
            template_extractor.rb
          ]
        end

        def source_under_test
          source_files.reject { |p| whitelist_files.include?(p.basename.to_s) }
        end

        it "contains no styleId string literals" do
          offenders = []
          source_under_test.each do |path|
            src = path.read
            all_style_ids.each do |sid|
              if src.match?(/["']#{Regexp.escape(sid)}["']/)
                offenders << "#{path}:#{sid}"
              end
            end
          end
          expect(offenders).to be_empty,
            "hardcoded styleIds found: #{offenders.inspect}"
        end

        it "contains no Heading# interpolation" do
          offenders = []
          source_under_test.each do |path|
            path.read.scan(/["']Heading#\{[^}]+\}["']/) do |m|
              offenders << "#{path}:#{m}"
            end
          end
          expect(offenders).to be_empty
        end

        it "contains no TOC# interpolation" do
          offenders = []
          source_under_test.each do |path|
            path.read.scan(/["']TOC#\{[^}]+\}["']/) do |m|
              offenders << "#{path}:#{m}"
            end
          end
          expect(offenders).to be_empty
        end

        it "contains no style fallback chains" do
          offenders = []
          source_under_test.each do |path|
            src = path.read
            if src.match?(/paragraph_style\([^)]+\)\s*\|\|/)
              offenders << path
            end
          end
          expect(offenders).to be_empty
        end

        it "does not call send on private methods" do
          offenders = []
          source_under_test.each do |path|
            path.read.scan(/\.send\(\s*:/) do |m|
              offenders << "#{path}:#{m}"
            end
          end
          expect(offenders).to be_empty
        end

        it "does not use respond_to? for type checks" do
          offenders = []
          source_under_test.each do |path|
            path.read.scan(/\.respond_to\?\s*\(?/) do |m|
              offenders << "#{path}:#{m}"
            end
          end
          expect(offenders).to be_empty
        end

        it "does not use require_relative" do
          offenders = []
          source_under_test.each do |path|
            path.read.scan(/^require_relative\s+/) do |m|
              offenders << "#{path}:#{m}"
            end
          end
          expect(offenders).to be_empty
        end
      end
    end
  end
end
```

## Whitelist rationale

The YAML loader (`docx_style_mapping.rb`), the `StyleLibrary`, the
`StyleMappingValidator`, and the `TemplateExtractor` legitimately name
styleIds because they read them from disk. The whitelist is exhaustive
and named: any new file that needs to read styleIds must be added
explicitly, forcing a design review.

## Acceptance criteria

- `bundle exec rspec spec/isodoc/iso/docx/adapter_purity_spec.rb`
  passes against the post-TODO 007/008 code.
- Inserting `style = "Heading#{level}"` anywhere in
  `lib/isodoc/iso/docx/` causes the spec to fail.
- Inserting `s = paragraph_style(:foo) || paragraph_style(:bar)` causes
  the spec to fail.

## Notes

- This is a static analysis spec — does not load the adapter. Fast and
  safe to run on its own (within the project's one-spec-file-at-a-time
  rule).
- Complements rubocop: rubocop catches stylistic issues; this spec
  enforces domain-specific invariants.
