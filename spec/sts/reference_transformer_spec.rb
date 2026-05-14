# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::ReferenceTransformer do
  let(:context) { make_context }
  let(:transformer) { described_class.new(context) }

  describe "#transform_bibitem" do
    it "builds mixed-citation with italic title" do
      bibitem = Metanorma::Document::Components::BibData::BibliographicItem.new
      bibitem.id = "ISO8601"

      doc_id = Metanorma::Document::Relaton::DocumentIdentifier.new
      doc_id.id = "ISO 8601-1:2019"
      doc_id.type = "ISO"
      bibitem.docidentifier = [doc_id]

      title = Metanorma::Document::Relaton::TypedTitleString.new
      title.type = "title-main"
      title.content = ["Date and time — Representations for information interchange"]
      bibitem.title = [title]

      result = transformer.transform_bibitem(bibitem, 1)
      xml = result.to_xml

      expect(xml).to include("<mixed-citation>")
      expect(xml).to include("ISO 8601-1:2019")
      expect(xml).to include("<italic>")
      expect(xml).to include("Date and time")
    end

    it "builds both dated and undated std-ref" do
      bibitem = Metanorma::Document::Components::BibData::BibliographicItem.new
      bibitem.id = "ISO8601"

      doc_id = Metanorma::Document::Relaton::DocumentIdentifier.new
      doc_id.id = "ISO 8601-1:2019"
      doc_id.type = "ISO"
      bibitem.docidentifier = [doc_id]

      result = transformer.transform_bibitem(bibitem, 1)
      xml = result.to_xml

      expect(xml).to include('type="dated"')
      expect(xml).to include("ISO 8601-1:2019")
      expect(xml).to include('type="undated"')
      expect(xml).to include("ISO 8601-1")
    end

    it "uses primary docidentifier when available" do
      bibitem = Metanorma::Document::Components::BibData::BibliographicItem.new
      bibitem.id = "ISO1234"

      primary = Metanorma::Document::Relaton::DocumentIdentifier.new
      primary.id = "ISO 1234:2025"
      primary.type = "ISO"
      primary.primary = true

      secondary = Metanorma::Document::Relaton::DocumentIdentifier.new
      secondary.id = "ISO 1234"
      secondary.type = "metanorma"

      bibitem.docidentifier = [secondary, primary]

      result = transformer.transform_bibitem(bibitem, 2)
      xml = result.to_xml

      expect(xml).to include("ISO 1234:2025")
    end

    it "generates sequential biblref IDs and labels" do
      bibitem = Metanorma::Document::Components::BibData::BibliographicItem.new
      bibitem.id = "ref1"

      doc_id = Metanorma::Document::Relaton::DocumentIdentifier.new
      doc_id.id = "ISO 9999"
      bibitem.docidentifier = [doc_id]

      result = transformer.transform_bibitem(bibitem, 5)
      xml = result.to_xml

      expect(xml).to include('id="biblref_5"')
      expect(xml).to include("<label>[5]</label>")
    end
  end
end
