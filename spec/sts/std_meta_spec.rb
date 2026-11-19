# frozen_string_literal: true

require_relative "spec_helper"
require "sts"

# Specs for the OIML STS <std-meta> migration.
#
# NISO STS V1.2 doesn't allow inventing new element names; the
# correct container for an OIML publication's front matter is
# <std-meta> (the generic catch-all for SDOs that aren't ISO,
# national, or regional bodies). sts-ruby 0.6.0 ships
# Sts::NisoSts::MetadataStd that serialises as <std-meta>; we route
# the transformer output to Front#std_meta (not Front#iso_meta) so
# OIML publications never carry <iso-meta>.
RSpec.describe "OIML STS <std-meta> front matter" do
  describe "Sts::NisoSts::MetadataStd serialisation" do
    it "emits <std-meta> and not <iso-meta>" do
      meta = Sts::NisoSts::MetadataStd.new(
        title_wrap: [Sts::NisoSts::TitleWrap.new(main: "Test title")],
        pub_date: "2026",
      )
      xml = meta.to_xml
      expect(xml).to include("<std-meta>")
      expect(xml).not_to include("<iso-meta>")
      expect(xml).to include("<main>Test title</main>")
      expect(xml).to include("<pub-date>2026</pub-date>")
    end

    it "round-trips title_wrap.main through from_xml → to_xml" do
      xml = <<~XML
        <std-meta>
          <title-wrap><main>OIML Encoding guidelines for publications in NISO STS</main></title-wrap>
          <pub-date>2026</pub-date>
        </std-meta>
      XML
      meta = Sts::NisoSts::MetadataStd.from_xml(xml)
      expect(meta.title_wrap.first.main).to eq("OIML Encoding guidelines for publications in NISO STS")
      expect(meta.pub_date).to eq("2026")
      expect(meta.to_xml).to include("<std-meta>")
      expect(meta.to_xml).not_to include("<iso-meta>")
    end
  end

  describe "Sts::NisoSts::Front routing" do
    it "routes <std-meta> to Front#std_meta (not Front#iso_meta)" do
      xml = <<~XML
        <front>
          <std-meta>
            <title-wrap><main>Test</main></title-wrap>
          </std-meta>
        </front>
      XML
      front = Sts::NisoSts::Front.from_xml(xml)
      expect(front.std_meta).to be_a(Sts::NisoSts::MetadataStd)
      expect(front.iso_meta).to be_nil
    end

    it "still routes <iso-meta> to Front#iso_meta (backward compat)" do
      xml = <<~XML
        <front>
          <iso-meta>
            <title-wrap><main>Legacy ISO</main></title-wrap>
          </iso-meta>
        </front>
      XML
      front = Sts::NisoSts::Front.from_xml(xml)
      expect(front.iso_meta).to be_a(Sts::NisoSts::MetadataIso)
      expect(front.std_meta).to be_nil
    end
  end

  describe "Metanorma::Iso::Sts::Transformer::ModelBuilder.std_meta" do
    it "builds a MetadataStd with title, identifier, permissions, custom-meta" do
      meta = Metanorma::Iso::Sts::Transformer::ModelBuilder.std_meta(
        doc_identifier: "OIML X 999:2026",
        title: "Test title",
        pub_date: 2026,
        permissions: Metanorma::Iso::Sts::Transformer::ModelBuilder.permissions(
          holder: "OIML", year: 2026,
        ),
        custom_meta_group: Metanorma::Iso::Sts::Transformer::ModelBuilder.custom_meta_group(
          name: "oiml-doc-series", value: "X",
        ),
      )
      expect(meta).to be_a(Sts::NisoSts::MetadataStd)
      expect(meta.title_wrap.first.main).to eq("Test title")
      expect(meta.pub_date).to eq("2026")
      xml = meta.to_xml
      expect(xml).to include("<std-meta>")
      expect(xml).to include("<doc-type>x</doc-type>")
      expect(xml).to include("<doc-number>999</doc-number>")
      expect(xml).to include("<meta-name>oiml-doc-series</meta-name>")
      expect(xml).not_to include("<iso-meta>")
    end
  end

  describe "Metanorma::Iso::Sts::Transformer::ModelBuilder.front" do
    it "assigns std_meta: to Front#std_meta (not Front#iso_meta)" do
      meta = Metanorma::Iso::Sts::Transformer::ModelBuilder.std_meta(title: "x")
      front = Metanorma::Iso::Sts::Transformer::ModelBuilder.front(std_meta: meta)
      expect(front.std_meta).to eq(meta)
      expect(front.iso_meta).to be_nil
    end
  end
end
