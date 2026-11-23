# frozen_string_literal: true

require_relative "../spec_helper"
require "zip"
require "nokogiri"

RSpec.describe "Word template paragraph spacing" do # rubocop:disable RSpec/DescribeClass
  %w[simple dis].each do |template|
    context "when using the #{template} template" do
      let(:template_state) do
        template_path = IsoDoc::Iso::DocxTemplates.template_path(template.to_sym)
        styles = Zip::File.open(template_path) do |zip|
          Nokogiri::XML(zip.find_entry("word/styles.xml").get_input_stream.read)
        end
        ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
        definition = styles.at_xpath("//w:style[@w:styleId='Definition']", ns)
        parent_id = definition.at_xpath("w:basedOn", ns)["w:val"]
        spacing_paths = ["//w:docDefaults/w:pPrDefault/w:pPr/w:spacing",
                         "//w:style[@w:styleId='Definition']/w:pPr/w:spacing",
                         "//w:style[@w:styleId='#{parent_id}']/w:pPr/w:spacing"]
        spacing_before = spacing_paths.map do |path|
          styles.at_xpath(path, ns)&.[]("w:before")
        end
        stylesheet_dir = File.expand_path("../../lib/isodoc/iso/html", __dir__)
        css_name = template == "simple" ? "isodoc.css" : "isodoc-dis.css"
        source_name = template == "simple" ? "isodoc.scss" : "isodoc-dis.scss"
        sources = [source_name, css_name].map do |file|
          File.read(File.join(stylesheet_dir, file))
        end
        color_names = template == "simple" ? %w[zzCopyright zzCopyright1 zzAddress] : %w[zzCopyright zzAddress]
        copyright_colors = sources.map do |source|
          # Liquid font placeholders contain braces that are not CSS boundaries.
          source = source.gsub(/\{\{[^{}]*\}\}/, "font")
          color_names.map do |name|
            rule = source[/p\.#{Regexp.escape(name)}(?=[,\s{])[^{}]*\{([^}]*)\}/m, 1]
            raise "missing p.#{name} rule" unless rule

            rule[/(?:\A|;)\s*color:\s*([^;]+)/, 1]
          end
        end
        definition_css = sources.last[/p\.Definition,\s*li\.Definition,\s*div\.Definition\s*\{[^}]*\}/m]
        copyright = styles.at_xpath("//w:style[@w:styleId='zzCopyright']", ns)
        border_colors = copyright.xpath("w:pPr/w:pBdr/*/@w:color", ns).map(&:value).uniq

        { spacing_before: spacing_before, definition_css: definition_css,
          copyright_colors: copyright_colors, border_colors: border_colors }
      end

      it "keeps Definition space-before at zero as in the template" do
        expect(template_state[:spacing_before]).to eq([nil, nil, nil])
      end

      it "sets effective Definition space-before to zero" do
        expect(template_state[:definition_css]).to match(/margin-top:\s*0cm;/)
      end

      it "applies the required copyright text colors in source and compiled CSS" do
        expected = template == "simple" ? Array.new(3, "blue") : [nil, nil]
        expect(template_state[:copyright_colors]).to eq([expected, expected])
      end

      it "preserves the template copyright border color" do
        expected = template == "simple" ? "0000FF" : "auto"
        expect(template_state[:border_colors]).to eq([expected])
      end
    end
  end

  context "when formatting authority copyright paragraphs" do
    let(:converter) { IsoDoc::Iso::WordConvert.allocate }
    let(:authority) { Nokogiri::HTML.fragment("<div><p>Copyright</p><p id='boilerplate-address'>Address</p></div>") }

    before do
      converter.send(:authority_copyright_style, authority)
    end

    it "does not inject inline text colors" do
      expect(authority.xpath(".//*[@style]")).to be_empty
    end
  end
end
