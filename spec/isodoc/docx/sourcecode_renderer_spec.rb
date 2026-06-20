# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::SourcecodeRenderer do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { adapter.send(:create_document) }
  let(:inline) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:renderer) { described_class.new(resolver, inline) }

  describe "#render with fmt_sourcecode" do
    it "renders code text as a single paragraph" do
      sourcecode = sourcecode_with_fmt(<<~XML.chomp)
        <fmt-sourcecode lang="ruby"><span class="nb">puts</span> "hi"</fmt-sourcecode>
      XML

      renderer.render(sourcecode, doc)
      para = doc.model.body.paragraphs.first

      expect(para.properties.style.value).to eq("Code")
      expect(collect_text(para)).to include('puts "hi"')
    end

    it "renders callouts as superscript runs with parens" do
      sourcecode = sourcecode_with_fmt(<<~XML.chomp)
        <fmt-sourcecode><span class="c"><callout target="_callout-1">1</callout></span></fmt-sourcecode>
      XML

      renderer.render(sourcecode, doc)
      para = doc.model.body.paragraphs.first

      callout_run = para.runs.find { |r| r.properties&.vertical_align }
      expect(callout_run).not_to be_nil
      expect(callout_run.properties.vertical_align.value).to eq("superscript")
      expect(callout_run.text.to_s).to eq("(1)")
    end

    it "preserves line breaks within code text" do
      sourcecode = sourcecode_with_fmt(<<~XML.chomp)
        <fmt-sourcecode>line one
line two</fmt-sourcecode>
      XML

      renderer.render(sourcecode, doc)
      para = doc.model.body.paragraphs.first

      breaks = para.runs.select { |r| r.break }
      expect(breaks.size).to eq(1)
    end

    it "skips block elements (dl) inside fmt-sourcecode" do
      sourcecode = sourcecode_with_fmt(<<~XML.chomp)
        <fmt-sourcecode>code<dl><dt>1</dt><dd>note</dd></dl></fmt-sourcecode>
      XML

      renderer.render(sourcecode, doc)
      para = doc.model.body.paragraphs.first

      expect(collect_text(para)).to eq("code")
    end
  end

  describe "#render with callout annotations" do
    it "emits annotation paragraphs after the code paragraph" do
      xml = <<~XML.chomp
        <sourcecode id="_s1" lang="ruby">
          <body>puts "hi"</body>
          <callout-annotation anchor="_callout-1" id="_ca1">
            <p>This is a note.</p>
          </callout-annotation>
          <fmt-sourcecode lang="ruby">puts "hi"</fmt-sourcecode>
        </sourcecode>
      XML

      sourcecode = Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock.from_xml(xml)
      renderer.render(sourcecode, doc)

      paragraphs = doc.model.body.paragraphs.to_a
      expect(paragraphs.size).to eq(2)
      expect(collect_text(paragraphs.first)).to include('puts "hi"')
      expect(collect_text(paragraphs.last)).to include("This is a note.")
    end
  end

  describe "#render falls back to body when no fmt_sourcecode" do
    it "renders body content as plain text" do
      xml = '<sourcecode id="_s1" lang="ruby"><body>plain code line</body></sourcecode>'
      sourcecode = Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock.from_xml(xml)

      renderer.render(sourcecode, doc)
      para = doc.model.body.paragraphs.first

      expect(collect_text(para)).to include("plain code line")
    end
  end

  def sourcecode_with_fmt(fmt_inner_xml)
    xml = "<sourcecode id=\"_s1\" lang=\"ruby\">#{fmt_inner_xml}</sourcecode>"
    Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock.from_xml(xml)
  end

  def collect_text(para)
    para.runs.map { |r| r.text.to_s }.join
  end
end
