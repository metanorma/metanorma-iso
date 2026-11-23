# frozen_string_literal: true

require_relative "spec_helper"
require_relative "../../support/layout_docx_helper"
require "tmpdir"

# Keep these regression specs beside the existing DOCX renderer specs.
# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Renderers::TableRenderer do
  include LayoutDocxHelper

  let(:width_attribute) { "" }
  let(:attachments) { "" }
  let(:table) { converted_width_table(width_attribute, attachments) }
  let(:grid) { table_grid_values(table) }

  it "writes a fixed full text width instead of an automatic width" do
    layout = table.at_xpath("w:tblPr/w:tblLayout/@w:type", layout_ns)&.value
    expect([table_width_values(table), layout]).to eq([["dxa", "10204"], "fixed"])
  end

  it "scales relative colgroup widths to twips" do
    expect(grid).to eq([2551, 7653])
  end

  it "keeps cell and spanning cell widths consistent with the grid" do
    cells = table.xpath("w:tr/w:tc/w:tcPr/w:tcW", layout_ns)
    expect(cells.map { |c| [c["w:w"].to_i, c["w:type"]] })
      .to eq([[2551, "dxa"], [7653, "dxa"], [10204, "dxa"]])
  end

  context "with an explicit author width" do
    let(:width_attribute) { 'width="8000"' }

    it "preserves the total and relative column proportions" do
      expect([table_width_values(table), grid]).to eq([["dxa", "8000"], [2000, 6000]])
    end
  end

  context "with an explicit percentage width" do
    let(:width_attribute) { 'width="50%"' }

    it "uses that fraction of the text width" do
      expect([table_width_values(table), grid]).to eq([["dxa", "5102"], [1275, 3827]])
    end
  end

  context "with an explicit physical width" do
    let(:width_attribute) { 'width="5in"' }

    it "converts the author width to twips" do
      expect([table_width_values(table), grid]).to eq([["dxa", "7200"], [1800, 5400]])
    end
  end

  context "with a table in Simple front matter" do
    let(:table) { converted_width_table(width_attribute, attachments, template: :simple, zone: :front) }

    it "uses the front section text width" do
      expect([table_width_values(table), grid]).to eq([["dxa", "9638"], [2409, 7229]])
    end

    context "with a percentage width" do
      let(:width_attribute) { 'width="50%"' }

      it "resolves the percentage against the front section" do
        expect([table_width_values(table), grid]).to eq([["dxa", "4819"], [1204, 3615]])
      end
    end

    context "with an explicit author width" do
      let(:width_attribute) { 'width="8000"' }

      it "preserves the explicit width" do
        expect([table_width_values(table), grid]).to eq([["dxa", "8000"], [2000, 6000]])
      end
    end
  end

  [[:simple, :body], [:dis, :front]].each do |template, zone|
    context "with a table in #{template} #{zone}" do
      let(:table) { converted_width_table(width_attribute, attachments, template: template, zone: zone) }

      it "uses the section text width" do
        expect([table_width_values(table), grid]).to eq([["dxa", "10204"], [2551, 7653]])
      end
    end
  end

  context "with a table nested in a cell" do
    let(:nested_width) { "" }
    let(:table) do
      nested = %(<table id="nested" #{nested_width}><tbody><tr><td>Inner</td></tr></tbody></table>)
      converted_width_table(width_attribute, attachments, cell_content: nested)
    end

    it "scales the nested grid to its containing column" do
      inner = table.at_xpath("w:tr/w:tc/w:tbl", layout_ns)
      expect([table_width_values(inner), table_grid_values(inner)]).to eq([["pct", "5000"], [2551]])
    end

    context "with an explicit percentage width" do
      let(:nested_width) { 'width="50%"' }

      it "resolves the percentage against the cell" do
        inner = table.at_xpath("w:tr/w:tc/w:tbl", layout_ns)
        expect([table_width_values(inner), table_grid_values(inner)]).to eq([["pct", "2500"], [1276]])
      end
    end

    context "with an explicit absolute width" do
      let(:nested_width) { 'width="1000"' }

      it "preserves a width that fits the cell" do
        inner = table.at_xpath("w:tr/w:tc/w:tbl", layout_ns)
        expect([table_width_values(inner), table_grid_values(inner)]).to eq([["dxa", "1000"], [1000]])
      end
    end
  end

  context "with attached notes" do
    let(:attachments) { '<note id="n1"><p>Table note.</p></note>' }

    it "sizes the wrapper to the section and the inner table to its cell" do
      inner = table.at_xpath("w:tr/w:tc/w:tbl", layout_ns)
      expect([grid, table_width_values(table), table_width_values(inner), table_grid_values(inner)])
        .to eq([[10204], ["dxa", "10204"], ["pct", "5000"], [2551, 7653]])
    end

    context "with an explicit percentage width" do
      let(:width_attribute) { 'width="50%"' }

      it "applies the author width once to the wrapper" do
        inner = table.at_xpath("w:tr/w:tc/w:tbl", layout_ns)
        expect([grid, table_width_values(inner), table_grid_values(inner)])
          .to eq([[5102], ["pct", "5000"], [1275, 3827]])
      end
    end

    it "keeps the wrapper borderless" do
      expect(table.at_xpath("w:tblPr/w:tblBorders", layout_ns)).to be_nil
    end
  end
end
