# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::TableTransformer do
  let(:context) { make_context }
  let(:transformer) { described_class.new(context) }

  describe "#transform_wrap" do
    it "transforms a table with thead and tbody" do
      source = Metanorma::Document::Components::Tables::TableBlock.new
      source.id = "_table_1"
      source.width = "100%"
      source.displayorder = 1

      thead = Metanorma::Document::Components::Tables::TableHeadSection.new
      header_row = Metanorma::Document::Components::Tables::TextTableRow.new
      th = Metanorma::Document::Components::Tables::HeaderTableCell.new
      th.text = ["Header"]
      header_row.th = [th]
      thead.tr = [header_row]
      source.thead = thead

      tbody = Metanorma::Document::Components::Tables::TableBodySection.new
      body_row = Metanorma::Document::Components::Tables::TextTableRow.new
      td = Metanorma::Document::Components::Tables::TextTableCell.new
      td.text = ["Cell"]
      body_row.td = [td]
      tbody.tr = [body_row]
      source.tbody = tbody

      result = transformer.transform_wrap(source)

      expect(result).to be_a(Sts::TbxIsoTml::TableWrap)
      xml = result.to_xml
      expect(xml).to include("<table-wrap")
      expect(xml).to include("<thead>")
      expect(xml).to include("<th>Header</th>")
      expect(xml).to include("<tbody>")
      expect(xml).to include("<td>Cell</td>")
    end

    it "preserves colspan and rowspan attributes" do
      source = Metanorma::Document::Components::Tables::TableBlock.new
      source.id = "_table_2"

      tbody = Metanorma::Document::Components::Tables::TableBodySection.new
      row = Metanorma::Document::Components::Tables::TextTableRow.new
      td = Metanorma::Document::Components::Tables::TextTableCell.new
      td.text = ["Span"]
      td.colspan = 2
      td.rowspan = 3
      row.td = [td]
      tbody.tr = [row]
      source.tbody = tbody

      result = transformer.transform_wrap(source)
      xml = result.to_xml
      expect(xml).to include('colspan="2"')
      expect(xml).to include('rowspan="3"')
    end
  end
end
