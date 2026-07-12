# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::InlineTransformer do
  let(:context) { make_context }
  let(:transformer) { described_class.new(context) }

  describe "#transform_fn (footnote integration)" do
    it "returns an xref instead of fn element" do
      fn_node = Metanorma::Document::Components::Inline::FnElement.new
      fn_node.id = "fn1"
      fn_node.reference = "1"

      p_node = Metanorma::IsoDocument::RawParagraph.new
      p_node.content = "This is a footnote"
      fn_node.p = [p_node]

      result = transformer.send(:transform_fn, fn_node)
      expect(result).to be_a(Sts::TbxIsoTml::Xref)
      expect(result.rid).to eq("fn_1")
      expect(result.ref_type).to eq("fn")
    end

    it "registers the footnote with the collector" do
      fn_node = Metanorma::Document::Components::Inline::FnElement.new
      fn_node.id = "fn1"

      p_node = Metanorma::IsoDocument::RawParagraph.new
      p_node.content = "Deduplicated text"
      fn_node.p = [p_node]

      transformer.send(:transform_fn, fn_node)
      transformer.send(:transform_fn, fn_node)

      expect(context.footnote_collector.count).to eq(1)
    end
  end

  describe "#transform_eref" do
    it "builds std with locality" do
      eref = Metanorma::Document::Components::Inline::ErefElement.new
      eref.bibitemid = "ISO8601"
      eref.citeas = "ISO 8601-1:2019"

      locality = Metanorma::Document::Relaton::BibItemLocality.new
      locality.type = "clause"
      locality.reference_from = "3.1"
      locality_stack = Metanorma::Document::Relaton::LocalityStack.new
      locality_stack.bib_locality = [locality]
      eref.locality_stack = [locality_stack]

      result = transformer.send(:transform_eref, eref)
      expect(result).to be_a(Sts::IsoSts::Std)
      xml = result.to_xml
      expect(xml).to include("ISO 8601-1:2019, clause 3.1")
    end
  end

  describe "#transform_xref" do
    it "remaps xref target IDs" do
      context.id_generator.register("_table_1", "tab_1")
      xref = Metanorma::Document::Components::Inline::XrefElement.new
      xref.target = "_table_1"

      result = transformer.send(:transform_xref, xref)
      expect(result.rid).to eq("tab_1")
    end
  end
end
