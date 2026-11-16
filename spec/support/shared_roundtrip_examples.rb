# frozen_string_literal: true

require "nokogiri"

# Shared examples for XML round-trip specs.
# Use in spec files via:
#   it_behaves_like "xml round-trip", flavor_dir: "ogc", doc_class: Metanorma::IsoDocument::Root
RSpec.shared_examples "xml round-trip" do |flavor_dir:, doc_class: Metanorma::IsoDocument::Root, full: true|
  fixtures = RoundtripHelper.discover_fixtures(flavor_dir: flavor_dir)

  fixtures.each do |fixture|
    describe fixture[:name] do
      let(:data) { RoundtripHelper.fixture_data(fixture[:path], doc_class) }
      let(:xml) { data[:xml] }
      let(:doc) { data[:doc] }
      let(:output_xml) { data[:output_xml] }
      let(:original_noko) { data[:original_noko] }
      let(:roundtrip_noko) { data[:roundtrip_noko] }

      it "parses without error" do
        expect(doc).to be_a(doc_class)
      end

      it "produces valid XML" do
        expect(RoundtripHelper).not_to be_xml_has_errors(output_xml)
      end

      it "round-trips root element and attributes" do
        expect(roundtrip_noko.root.name).to eq("metanorma")
        expect(roundtrip_noko.root["type"]).to eq(original_noko.root["type"])
        expect(roundtrip_noko.root["flavor"]).to eq(original_noko.root["flavor"])
      end

      it "round-trips bibdata type" do
        expect(RoundtripHelper.bibdata_type(roundtrip_noko)).to eq(RoundtripHelper.bibdata_type(original_noko))
      end

      it "round-trips titles" do
        expect(RoundtripHelper.bibdata_titles(roundtrip_noko)).to eq(RoundtripHelper.bibdata_titles(original_noko))
      end

      it "round-trips status stage" do
        expect(RoundtripHelper.status_stage(roundtrip_noko)).to eq(RoundtripHelper.status_stage(original_noko))
      end

      it "round-trips section clause IDs" do
        expect(RoundtripHelper.section_clause_ids(roundtrip_noko)).to eq(RoundtripHelper.section_clause_ids(original_noko))
      end

      it "round-trips preface" do
        expect(RoundtripHelper.has_preface?(roundtrip_noko)).to eq(RoundtripHelper.has_preface?(original_noko))
      end

      it "round-trips annex IDs" do
        expect(RoundtripHelper.annex_ids(roundtrip_noko)).to eq(RoundtripHelper.annex_ids(original_noko))
      end

      it "round-trips bibliography references sections" do
        expect(RoundtripHelper.bibliography_references_count(roundtrip_noko)).to eq(RoundtripHelper.bibliography_references_count(original_noko))
      end

      it "round-trips bibliography normative attributes" do
        expect(RoundtripHelper.bibliography_normative_attrs(roundtrip_noko)).to eq(RoundtripHelper.bibliography_normative_attrs(original_noko))
      end

      if full
        it "round-trips term IDs" do
          expect(RoundtripHelper.term_ids(roundtrip_noko)).to eq(RoundtripHelper.term_ids(original_noko))
        end

        it "round-trips table IDs" do
          expect(RoundtripHelper.table_ids(roundtrip_noko)).to eq(RoundtripHelper.table_ids(original_noko))
        end

        it "round-trips figure IDs" do
          expect(RoundtripHelper.figure_ids(roundtrip_noko)).to eq(RoundtripHelper.figure_ids(original_noko))
        end

        it "round-trips formula IDs" do
          expect(RoundtripHelper.formula_ids(roundtrip_noko)).to eq(RoundtripHelper.formula_ids(original_noko))
        end

        it "round-trips nested clause structure" do
          expect(RoundtripHelper.nested_clause_ids(roundtrip_noko)).to eq(RoundtripHelper.nested_clause_ids(original_noko))
        end
      end

      if fixture[:xml_type] == "presentation"
        it "preserves type=presentation on root" do
          expect(roundtrip_noko.root["type"]).to eq("presentation")
        end

        if full
          it "round-trips inline-header attributes" do
            expect(RoundtripHelper.inline_header_count(roundtrip_noko)).to eq(RoundtripHelper.inline_header_count(original_noko))
          end
        end
      end
    end
  end
end

RSpec.shared_examples "collection round-trip" do |flavor_dir:|
  require "metanorma/collection"

  collections = RoundtripHelper.discover_collections(flavor_dir: flavor_dir)

  collections.each do |fixture|
    describe fixture[:name] do
      let(:data) do
        RoundtripHelper.fixture_data(fixture[:path],
                                     Metanorma::Collection::Root)
      end
      let(:xml) { data[:xml] }
      let(:doc) { data[:doc] }
      let(:output_xml) { data[:output_xml] }
      let(:original_noko) { data[:original_noko] }
      let(:roundtrip_noko) { data[:roundtrip_noko] }

      it "parses without error" do
        expect(doc).to be_a(Metanorma::Collection::Root)
      end

      it "produces valid XML" do
        expect(RoundtripHelper).not_to be_xml_has_errors(output_xml)
      end

      it "round-trips root element name" do
        expect(roundtrip_noko.root.name).to eq("metanorma-collection")
      end

      it "round-trips collection bibdata type" do
        expect(RoundtripHelper.bibdata_type(roundtrip_noko)).to eq("collection")
      end

      it "round-trips collection title" do
        orig_title = original_noko.at_css("bibdata > title")&.text&.strip
        rt_title = roundtrip_noko.at_css("bibdata > title")&.text&.strip
        expect(rt_title).to eq(orig_title)
      end

      it "round-trips collection docidentifier" do
        orig_id = original_noko.at_css("bibdata > docidentifier")&.text&.strip
        rt_id = roundtrip_noko.at_css("bibdata > docidentifier")&.text&.strip
        expect(rt_id).to eq(orig_id)
      end

      it "round-trips directive count" do
        expect(RoundtripHelper.collection_directive_count(roundtrip_noko)).to eq(
          RoundtripHelper.collection_directive_count(original_noko),
        )
      end

      it "round-trips entry count" do
        expect(RoundtripHelper.collection_entry_count(roundtrip_noko)).to eq(
          RoundtripHelper.collection_entry_count(original_noko),
        )
      end

      it "round-trips doc-container count" do
        expect(RoundtripHelper.doc_container_count(roundtrip_noko)).to eq(
          RoundtripHelper.doc_container_count(original_noko),
        )
      end

      it "round-trips doc-container IDs" do
        expect(RoundtripHelper.doc_container_ids(roundtrip_noko)).to eq(
          RoundtripHelper.doc_container_ids(original_noko),
        )
      end

      it "round-trips embedded document docidentifiers" do
        expect(RoundtripHelper.doc_container_docidentifiers(roundtrip_noko)).to eq(
          RoundtripHelper.doc_container_docidentifiers(original_noko),
        )
      end
    end
  end
end
