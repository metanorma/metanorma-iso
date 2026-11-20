# frozen_string_literal: true

require_relative "spec_helper"
require "metanorma-iso"
require "tmpdir"

# rubocop:disable RSpec/MultipleExpectations, RSpec/InstanceVariable, RSpec/BeforeAfterAll, RSpec/ExampleLength, RSpec/DescribeClass
module RiceDocxE2E
  W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  M = "http://schemas.openxmlformats.org/officeDocument/2006/math"
  R = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  NS = { "w" => W, "m" => M, "r" => R }.freeze
  PACKAGE_REL = "http://schemas.openxmlformats.org/package/2006/relationships"
  BOX = %w[Box-begin Box-end].freeze
end

# Full rice end-to-end coverage of the DOCX output (card P3-005). The rice
# presentation XML is converted ONCE for the whole file (before(:all)); every
# example then asserts a structural PROPERTY of the package rather than a
# snapshot count: each reference resolves, nothing is duplicated, every style
# and numbering id used is defined, the body is closed by a sectPr.
#
# Run it on its own, in the foreground (about 50 s, memory heavy):
#
#   bundle exec rspec spec/isodoc/docx/rice_docx_e2e_spec.rb
#
# CI: `rake` runs it through the :docx_e2e_spec task (see Rakefile).
RSpec.describe "Rice DOCX end-to-end" do
  before(:all) do
    Dir.mktmpdir("rice-docx-e2e-") do |dir|
      path = File.join(dir, "rice.docx")
      Metanorma::Iso::Processor.new.output(
        nil, File.expand_path("spec/examples/rice.presentation.xml", Dir.pwd),
        path, :docx
      )
      Zip::File.open(path) do |zip|
        @entries = zip.map(&:name)
        @parts = zip.entries.select { |e| e.name.end_with?(".xml", ".rels") }
          .to_h { |e| [e.name, Nokogiri::XML(zip.read(e))] }
        @media_sizes = zip.entries.select { |e| e.name.start_with?("word/media/") }
          .to_h { |e| [e.name, e.size] }
      end
    end
    @source = Nokogiri::XML(File.read("spec/examples/rice.presentation.xml"))
    @source.remove_namespaces!
  end

  def part(name) = @parts.fetch(name)
  def document = part("word/document.xml")
  def style_ids = part("word/styles.xml").xpath("//w:style/@w:styleId", RiceDocxE2E::NS).map(&:value)
  def bookmark_names = document.xpath("//w:bookmarkStart/@w:name", RiceDocxE2E::NS).map(&:value)

  def style_parts
    @parts.select { |n, _| n.match?(%r{\Aword/(document|footnotes|endnotes|comments|header\d+|footer\d+)\.xml\z}) }
  end

  def rel_targets(part_name)
    rels = part("word/_rels/#{File.basename(part_name)}.rels")
    rels.xpath("//xmlns:Relationship", "xmlns" => RiceDocxE2E::PACKAGE_REL)
      .to_h { |r| [r["Id"], r] }
  end

  describe "styles" do
    it "defines every pStyle and rStyle used in any story part in styles.xml" do
      defined = style_ids
      missing = style_parts.flat_map do |name, xml|
        used = xml.xpath("//w:pStyle/@w:val|//w:rStyle/@w:val", RiceDocxE2E::NS).map(&:value).uniq
        (used - defined).map { |id| "#{name}: #{id}" }
      end
      expect(missing).to be_empty, "styleIds used but not defined: #{missing.inspect}"
    end

    it "uses no excluded (pollution) styleIds" do
      excluded = IsoDoc::Iso::DocxStyleMapping.load_default.excluded_style_ids
      used = style_parts.values.flat_map do |xml|
        xml.xpath("//w:pStyle/@w:val|//w:rStyle/@w:val", RiceDocxE2E::NS).map(&:value)
      end
      expect(used.uniq & excluded.to_a).to be_empty
    end

    it "keeps styleIds unique in styles.xml" do
      expect(style_ids.tally.select { |_, n| n > 1 }.keys).to be_empty
    end
  end

  describe "numbering" do
    it "defines every numId referenced by the body or by a style" do
      defined = part("word/numbering.xml").xpath("//w:num/@w:numId", RiceDocxE2E::NS).map(&:value)
      used = (document.xpath("//w:numId/@w:val", RiceDocxE2E::NS) +
              part("word/styles.xml").xpath("//w:numId/@w:val", RiceDocxE2E::NS)).map(&:value).uniq - ["0"]
      expect(used - defined).to be_empty, "numIds used but not defined: #{used - defined}"
    end

    it "binds heading numbering through the style cascade, not paragraph numPr" do
      styles = part("word/styles.xml")
      h1 = styles.at_xpath("//w:style[@w:styleId='Heading1']//w:numId/@w:val", RiceDocxE2E::NS)
      annex = styles.at_xpath("//w:style[@w:styleId='ANNEX']//w:numId/@w:val", RiceDocxE2E::NS)
      expect(h1).not_to be_nil
      expect(annex).not_to be_nil
      expect(annex.value).not_to eq(h1.value)
      paras = document.xpath("//w:p[w:pPr/w:pStyle/@w:val='Heading1' or w:pPr/w:pStyle/@w:val='ANNEX']", RiceDocxE2E::NS)
      expect(paras).not_to be_empty
      expect(paras.xpath("w:pPr/w:numPr", RiceDocxE2E::NS)).to be_empty
    end

    it "emits one ANNEX paragraph per source annex" do
      count = document.xpath("//w:p[w:pPr/w:pStyle/@w:val='ANNEX']", RiceDocxE2E::NS).size
      expect(count).to eq(@source.xpath("//annex").size)
    end
  end

  describe "bookmarks and hyperlinks" do
    it "has no duplicate bookmark names" do
      expect(bookmark_names.tally.select { |_, n| n > 1 }.keys).to be_empty
    end

    it "has no duplicate bookmark ids and pairs every start with an end" do
      starts = document.xpath("//w:bookmarkStart/@w:id", RiceDocxE2E::NS).map(&:value)
      ends = document.xpath("//w:bookmarkEnd/@w:id", RiceDocxE2E::NS).map(&:value)
      expect(starts.tally.select { |_, n| n > 1 }.keys).to be_empty
      expect(starts.sort).to eq(ends.sort)
    end

    it "resolves every internal hyperlink anchor (xref, eref and TOC) to a bookmark" do
      anchors = document.xpath("//w:hyperlink/@w:anchor", RiceDocxE2E::NS).map(&:value)
      expect(anchors).not_to be_empty
      expect(anchors - bookmark_names).to be_empty
    end

    it "resolves every external hyperlink r:id to a relationship" do
      ids = document.xpath("//w:hyperlink/@r:id", RiceDocxE2E::NS).map(&:value)
      expect(ids - rel_targets("word/document.xml").keys).to be_empty
    end
  end

  describe "footnotes" do
    it "has a footnote body for every footnote reference" do
      refs = document.xpath("//w:footnoteReference/@w:id", RiceDocxE2E::NS).map(&:value).uniq
      bodies = part("word/footnotes.xml").xpath("//w:footnote[not(@w:type)]/@w:id", RiceDocxE2E::NS).map(&:value)
      expect(refs).not_to be_empty
      expect(refs - bodies).to be_empty, "references without a body: #{refs - bodies}"
      expect(bodies - refs).to be_empty, "bodies never referenced: #{bodies - refs}"
    end
  end

  describe "package structure" do
    it "ends the body with the final sectPr" do
      expect(document.at_xpath("//w:body", RiceDocxE2E::NS).element_children.last.name).to eq("sectPr")
    end

    it "resolves every header/footer reference to an existing part" do
      rels = rel_targets("word/document.xml")
      ids = document.xpath("//w:sectPr/w:headerReference/@r:id|//w:sectPr/w:footerReference/@r:id", RiceDocxE2E::NS)
        .map(&:value)
      expect(ids).not_to be_empty
      targets = ids.map { |id| rels.fetch(id)["Target"] }
      expect(targets.map { |t| "word/#{t}" } - @entries).to be_empty
    end

    it "resolves every r:id / r:embed used in the body to a relationship" do
      used = document.xpath("//@r:id|//@r:embed", RiceDocxE2E::NS).map(&:value).uniq
      expect(used - rel_targets("word/document.xml").keys).to be_empty
    end

    it "gives every drawing a unique docPr id" do
      ids = document.xpath("//wp:docPr/@id", "wp" => "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing")
        .map(&:value)
      expect(ids.tally.select { |_, n| n > 1 }.keys).to be_empty
    end
  end

  describe "images" do
    it "embeds one non-empty media part per source image" do
      drawings = document.xpath("//w:drawing", RiceDocxE2E::NS)
      expect(drawings.size).to eq(@source.xpath("//image").size)
      rels = rel_targets("word/document.xml")
      drawings.each do |drawing|
        embed = drawing.at_xpath(".//a:blip/@r:embed", RiceDocxE2E::NS.merge("a" => "http://schemas.openxmlformats.org/drawingml/2006/main"))
        target = "word/#{rels.fetch(embed.value)['Target']}"
        expect(@media_sizes.fetch(target)).to be_positive
      end
    end

    it "sets every image paragraph in an image style" do
      styles = document.xpath("//w:drawing", RiceDocxE2E::NS).map do |d|
        d.ancestors.find { |a| a.name == "p" && a.namespace&.href == RiceDocxE2E::W }
          .at_xpath("w:pPr/w:pStyle/@w:val", RiceDocxE2E::NS)&.value
      end
      expect(styles).to all(match(/\A(FigureGraphic|Dimension(50|75|100))\z/))
    end
  end

  describe "math (OMML)" do
    let(:block_stems) { @source.xpath("//formula/fmt-stem").size }
    # Source stems that are rendered in the body: the original <fn> and the
    # <fmt-fn-body> copies are rendered in footnotes.xml, not in the body.
    let(:inline_stems) do
      @source.xpath("//fmt-stem[not(parent::formula)][not(ancestor::fn)][not(ancestor::fmt-fn-body)]").size
    end

    it "renders every block formula as an m:oMathPara" do
      expect(block_stems).to be_positive
      expect(document.xpath("//m:oMathPara", RiceDocxE2E::NS).size).to eq(block_stems)
    end

    it "renders every inline stem as an m:oMath inside its paragraph" do
      inline = document.xpath("//m:oMath[not(parent::m:oMathPara)]", RiceDocxE2E::NS)
      expect(inline.size).to eq(inline_stems)
      expect(inline.map { |o| o.parent.name }.uniq).to eq(["p"])
    end

    it "keeps inline math next to its sentence text (same paragraph)" do
      mixed = document.xpath("//w:p[m:oMath][w:r/w:t]", RiceDocxE2E::NS)
        .reject { |p| p.at_xpath("m:oMathPara", RiceDocxE2E::NS) }
        .select { |p| p.xpath("w:r/w:t", RiceDocxE2E::NS).map(&:text).join.strip.length > 10 }
      expect(mixed).not_to be_empty
    end

    it "leaves no raw math fallback text in place of a stem" do
      text = document.xpath("//w:t", RiceDocxE2E::NS).map(&:text).join
      expect(text).not_to match(/<math|<mml:|<m:oMath/)
    end
  end

  describe "block layout" do
    it "keeps Box-begin / Box-end paragraphs balanced and alternating" do
      marks = document.xpath("//w:p/w:pPr/w:pStyle/@w:val", RiceDocxE2E::NS).map(&:value)
        .select { |s| RiceDocxE2E::BOX.include?(s) }
      expect(marks).not_to be_empty
      expect(marks.each_slice(2).to_a).to all(eq(RiceDocxE2E::BOX))
    end

    it "gives Disp-quotep paragraphs no manual indent" do
      quotes = document.xpath("//w:p[w:pPr/w:pStyle/@w:val='Disp-quotep']", RiceDocxE2E::NS)
      expect(quotes.size).to eq(@source.xpath("//quote").size)
      expect(quotes.xpath("w:pPr/w:ind", RiceDocxE2E::NS)).to be_empty
    end

    it "balances formula key titles and texts" do
      titles = document.xpath("//w:p[w:pPr/w:pStyle/@w:val='KeyTitle']", RiceDocxE2E::NS).size
      texts = document.xpath("//w:p[w:pPr/w:pStyle/@w:val='KeyText']", RiceDocxE2E::NS).size
      expect(titles).to eq(texts)
    end

    it "ends every table cell with a paragraph" do
      expect(document.xpath("//w:tc[*[last()][not(self::w:p)]]", RiceDocxE2E::NS).size).to eq(0)
    end
  end

  describe "headers and footers" do
    def default_footer_styles
      rels = rel_targets("word/document.xml")
      document.xpath("//w:sectPr", RiceDocxE2E::NS).map do |sect|
        ref = sect.at_xpath("w:footerReference[@w:type='default']/@r:id", RiceDocxE2E::NS)
        next unless ref

        part("word/#{rels.fetch(ref.value)['Target']}").xpath("//w:pStyle/@w:val", RiceDocxE2E::NS).map(&:value).grep(/\AFooterPage/).first
      end
    end

    it "uses HeaderCentered for every styled header paragraph" do
      styles = @parts.select { |n, _| n.match?(%r{\Aword/header\d+\.xml\z}) }.values
        .flat_map { |x| x.xpath("//w:pStyle/@w:val", RiceDocxE2E::NS).map(&:value) }
      expect(styles).not_to be_empty
      expect(styles.uniq).to eq(["HeaderCentered"])
    end

    it "numbers front matter in roman and the body in arabic, in that order" do
      styles = default_footer_styles.compact
      expect(styles.uniq - %w[FooterPageRomanNumber FooterPageNumber]).to be_empty
      expect(styles.last).to eq("FooterPageNumber")
      expect(styles).to eq(styles.sort_by { |s| s == "FooterPageNumber" ? 1 : 0 })
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/InstanceVariable, RSpec/BeforeAfterAll, RSpec/ExampleLength, RSpec/DescribeClass
