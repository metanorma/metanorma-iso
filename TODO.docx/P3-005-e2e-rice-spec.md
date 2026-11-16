# 023 — Spec: End-to-end rice DOCX output

## Goal

End-to-end spec that drives the full adapter with the rice
presentation XML and asserts structural properties of the generated
DOCX against the DIS 15926 reference. This is the system-level
acceptance test for Phase 3 (Era C feature mappings).

## Constraints

Per `CLAUDE.md`:

- **NEVER load rice presentation XML in a background task** — memory
  exhaustion. The spec must be invoked explicitly by the developer
  on the foreground, one spec file at a time.
- This spec is the slowest in the suite and **must never** be included
  in any rake task that runs the full suite.
- It is gated behind a `:slow` tag so it is excluded from default runs.

## What the spec asserts

The generated DOCX is unpacked to a temp dir; assertions are made on
the resulting `word/document.xml`, `word/styles.xml`,
`word/numbering.xml`, and `word/header*.xml`/`word/footer*.xml`.

1. **StyleId set is a subset of DIS 15926 styleIds**. The generated
   `document.xml` may only reference styleIds that exist in the
   reference's `styles.xml` (or in our `styles.yml`).
2. **No pollution styleIds**. None of the 500 pollution styles from
   `BUGS.gen/021` appear in the output.
3. **Heading numbering**. Each body Heading1 paragraph has
   `<w:numId w:val="4"/>`; each ANNEX paragraph has
   `<w:numId w:val="7"/>`. Heading2-6 have no explicit numPr.
4. **Box wrapping**. Every `<note>`, `<example>`, `<warning>` in the
   source has corresponding `Box-begin` / `Box-end` paragraphs in the
   output.
5. **Formula key lists**. Every formula `<dl>` renders as
   `KeyTitle` + `KeyText` paragraphs (TODO 011 closes the pending
   task #49).
6. **Dimension styles**. Every figure with an image renders inside a
   paragraph whose style is one of `Dimension50`, `Dimension75`,
   `Dimension100`.
7. **Disp-quotep**. Every `<quote>` renders as a `Disp-quotep`
   paragraph with no manual indent.
8. **Header/footer wiring**. Cover sections have
   `FooterPageRomanNumber`; body sections have `FooterPageNumber`;
   headers use `HeaderCentered`.
9. **Inline code**. Every `<tt>`/`<code>` run has
   `w:rStyle val="InlineCode"` (or `InlineCodeBold` if bold).

## File layout

```
spec/isodoc/iso/docx/
  rice_end_to_end_spec.rb
  support/
    docx_unpacker.rb
    style_id_asserter.rb
```

## Spec sketch

```ruby
require "spec_helper"
require "isodoc/iso/docx"
require "support/docx/docx_unpacker"
require "support/docx/style_id_asserter"

module IsoDoc
  module Iso
    module Docx
      RSpec.describe "Rice DOCX end-to-end", :slow do
        let(:presentation_xml) do
          Pathname("spec/fixtures/rice-iso.presentation.xml").read
        end
        let(:output_path) do
          tmp = Tempfile.new(["rice-e2e", ".docx"])
          tmp.close
          tmp.path
        end
        let(:unpacked) { DocxUnpacker.unpack(output_path) }

        before do
          IsoDoc::Iso::Docx::Adapter.convert(
            presentation_xml,
            output_path,
            { template_dir: "data/iso-dis" }
          )
        end

        after do
          FileUtils.rm_f(output_path)
          unpacked.cleanup if unpacked.respond_to?(:cleanup)
        end

        describe "styleIds" do
          it "uses only Era C styleIds" do
            asserter = StyleIdAsserter.new(
              unpacked.styles_xml,
              library: StyleLibrary.load_default
            )
            expect(asserter.unknown_style_ids).to be_empty,
              "Output uses styleIds not in Era C library: " +
              asserter.unknown_style_ids.inspect
          end

          it "uses no pollution styleIds" do
            excluded = DocxStyleMapping.load_default.excluded_style_ids
            asserter = StyleIdAsserter.new(
              unpacked.document_xml,
              library: StyleLibrary.load_default
            )
            expect(asserter.used_style_ids & excluded).to be_empty
          end
        end

        describe "heading numbering" do
          it "Heading1 in body uses numId=4, ilvl=0" do
            headings = unpacked.document_xml.css(
              "p[pStyle[val='Heading1']]"
            )
            expect(headings).not_to be_empty
            headings.each do |p|
              num_pr = p.at_css("numPr")
              expect(num_pr).to be_present
              expect(num_pr.at_css("numId")["val"]).to eq("4")
              expect(num_pr.at_css("ilvl")["val"]).to eq("0")
            end
          end

          it "ANNEX uses numId=7" do
            annexes = unpacked.document_xml.css(
              "p[pStyle[val='ANNEX']]"
            )
            expect(annexes).not_to be_empty
            annexes.each do |p|
              num_pr = p.at_css("numPr")
              expect(num_pr).to be_present
              expect(num_pr.at_css("numId")["val"]).to eq("7")
            end
          end

          it "Heading2-6 have no explicit numPr" do
            (2..6).each do |lvl|
              subs = unpacked.document_xml.css(
                "p[pStyle[val='Heading#{lvl}']]"
              )
              subs.each do |p|
                expect(p.at_css("numPr")).to be_nil
              end
            end
          end
        end

        describe "Box wrapping" do
          it "every note is wrapped in Box-begin/Box-end" do
            notes = unpacked.document_xml.css(
              "p[pStyle[val='Noteindent']]"
            )
            expect(notes).not_to be_empty
            notes.each do |n|
              prev_para = n.previous_element
              expect(prev_para.at_css("pStyle")["val"])
                .to eq("Box-begin").or eq("Box-title")
              next_para = n.following_element
              expect(next_para.at_css("pStyle")["val"])
                .to eq("Box-end").or eq("Noteindentcontinued")
            end
          end
        end

        describe "formula key lists" do
          it "every formula dl has KeyTitle entries" do
            key_titles = unpacked.document_xml.css(
              "p[pStyle[val='KeyTitle']]"
            )
            key_texts = unpacked.document_xml.css(
              "p[pStyle[val='KeyText']]"
            )
            expect(key_titles.size).to eq(key_texts.size)
          end
        end

        describe "image dimensions" do
          it "every figure paragraph uses Dimension*" do
            drawings = unpacked.document_xml.css("w:drawing")
            drawings.each do |d|
              para = d.ancestors("p").first
              style = para.at_css("pStyle")
              expect(style["val"]).to match(/^Dimension(50|75|100)$/)
            end
          end
        end

        describe "block quotes" do
          it "uses Disp-quotep with no manual indent" do
            quotes = unpacked.document_xml.css(
              "p[pStyle[val='Disp-quotep']]"
            )
            quotes.each do |q|
              expect(q.at_css("pPr/ind")).to be_nil
            end
          end
        end

        describe "headers/footers" do
          it "uses HeaderCentered for headers" do
            unpacked.headers.each do |_, xml|
              style = xml.at_css("pStyle")
              next unless style
              expect(style["val"]).to eq("HeaderCentered")
            end
          end

          it "cover footer uses FooterPageRomanNumber" do
            cover_footer = unpacked.footer_for(section: :cover)
            style = cover_footer.at_css("pStyle")
            expect(style["val"]).to eq("FooterPageRomanNumber")
          end

          it "body footer uses FooterPageNumber" do
            body_footer = unpacked.footer_for(section: :body)
            style = body_footer.at_css("pStyle")
            expect(style["val"]).to eq("FooterPageNumber")
          end
        end

        describe "inline code" do
          it "uses InlineCode rStyle for tt elements" do
            inline_code_runs = unpacked.document_xml.css(
              "r[rStyle[val='InlineCode']]"
            )
            expect(inline_code_runs).not_to be_empty
          end
        end
      end
    end
  end
end
```

## Required support code

### `DocxUnpacker`

```ruby
# spec/support/docx/docx_unpacker.rb
module IsoDoc
  module Iso
    module Docx
      class DocxUnpacker
        def self.unpack(docx_path)
          dir = Dir.mktmpdir("docx-unpack")
          Zip::File.open(docx_path) do |zip|
            zip.each { |entry| entry.extract(File.join(dir, entry.name)) }
          end
          new(dir)
        end

        def initialize(dir) ; @dir = dir ; end

        def document_xml ; Nokogiri::XML(File.read("#{@dir}/word/document.xml")) ; end
        def styles_xml   ; Nokogiri::XML(File.read("#{@dir}/word/styles.xml"))   ; end
        def numbering_xml; Nokogiri::XML(File.read("#{@dir}/word/numbering.xml")); end

        def headers
          Dir["#{@dir}/word/header*.xml"].each_with_object({}) do |f, h|
            h[File.basename(f, ".xml")] = Nokogiri::XML(File.read(f))
          end
        end

        def footers ; Dir["#{@dir}/word/footer*.xml"] ; end

        def footer_for(section:)
          # Uses sectPr lookup to find the matching footer by section ID
          ...
        end

        def cleanup ; FileUtils.rm_rf(@dir) ; end
      end
    end
  end
end
```

### `StyleIdAsserter`

```ruby
# spec/support/docx/style_id_asserter.rb
module IsoDoc
  module Iso
    module Docx
      class StyleIdAsserter
        def initialize(xml, library:)
          @xml = xml
          @library = library
        end

        def used_style_ids
          @xml.css("pStyle, rStyle").map { |e| e["val"] }.uniq
        end

        def unknown_style_ids
          used_style_ids - @library.all_style_ids
        end
      end
    end
  end
end
```

## Acceptance criteria

- `bundle exec rspec spec/isodoc/iso/docx/rice_end_to_end_spec.rb` runs
  to completion in the foreground (no `&`, no background task).
- Every assertion passes against adapter output generated after
  TODO 001-018 land.
- The spec produces a clear failure message naming the offending
  styleId, missing numId, or unwrapped note when a regression occurs.
- `canon diff` between the spec's `output_path` and
  `data/iso-rice-sample-output.docx` shows no missing style references
  beyond what is already documented as known structural diff.

## Anti-patterns rejected by this spec

- **Loading rice XML in a background task** — explicitly forbidden.
- **Comparing file sizes or element counts** — these are not semantic.
  Use `canon diff` or `uniword diff compare` instead.
- **Shell swapping parts from another DOCX** — explicitly forbidden.
- **Using `double()`** — every model object must be the real
  `Metanorma::Document` instance produced by `from_xml`.

## Notes

- This is the single most expensive spec in the suite. Run only when
  an integration regression is suspected.
- The slow tag is configured in `.rspec` as `--tag ~slow` to exclude
  by default; developers opt in with `--tag slow`.
