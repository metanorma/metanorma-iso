# frozen_string_literal: true

require_relative "spec_helper"

# Each example pins one place where the Ruby validator must agree with the
# vendored iso-sts.sch predicate (inputs from the review of PR #1870).
# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe Metanorma::Iso::Sts::Validator do
  def ids(inner, attrs: "")
    xml = %(<standard xmlns:tbx="urn:iso:std:iso:30042:ed-1" xmlns:xlink="http://www.w3.org/1999/xlink"#{attrs}>) \
          "#{inner}</standard>"
    described_class.new.validate(xml).errors.map(&:rule_id)
  end

  def legend(title, tag: "fig")
    %(<#{tag}><legend><title>#{title}</title><def-list><def-item><term>a</term><def><p>b</p></def></def-item></def-list></legend></#{tag}>)
  end

  describe "required and empty enumerated attributes" do
    it "fails an <app> with no @content-type (4.5.1-1)" do
      expect(ids("<app><label>Annex A</label><title>T</title></app>"))
        .to include("iso-gdg-4.5.1-1")
    end

    it "fails a <list> with no @list-type (5.7-2)" do
      expect(ids("<list><list-item><p>x</p></list-item></list>"))
        .to include("iso-gdg-5.7-2")
    end

    it "fails an empty <tbx:partOfSpeech> (9.2.3-2)" do
      expect(ids("<tbx:partOfSpeech/>")).to include("iso-gdg-9.2.3-2")
    end

    it "fails an empty <tbx:termType> (9.2.3-3)" do
      expect(ids("<tbx:termType/>")).to include("iso-gdg-9.2.3-3")
    end

    it "fails an empty <tbx:normativeAuthorization> (9.2.3-4)" do
      expect(ids("<tbx:normativeAuthorization/>")).to include("iso-gdg-9.2.3-4")
    end

    it "fails an explicitly empty optional @width (6.1-2)" do
      expect(ids(%(<table width=""/>))).to include("iso-gdg-6.1-2")
    end

    it "fails an explicitly empty optional @orientation (8.1-1)" do
      expect(ids(%(<fig orientation=""/>))).to include("iso-gdg-8.1-1")
    end

    it "still accepts an absent optional @width" do
      expect(ids("<table/>")).not_to include("iso-gdg-6.1-2")
    end

    it "still accepts a valid @list-type" do
      expect(ids(%(<list list-type="bullet"><list-item><p>x</p></list-item></list>)))
        .not_to include("iso-gdg-5.7-2")
    end
  end

  describe "guidelines edition meta-value (4.3.2-7)" do
    let(:meta) do
      "<processing-meta><custom-meta-group><custom-meta>" \
        "<meta-name>iec_iso_coding_guidelines_edition</meta-name>%s" \
        "</custom-meta></custom-meta-group></processing-meta>"
    end

    it "fails an empty <meta-value/>" do
      expect(ids(format(meta, "<meta-value/>"))).to include("iso-gdg-4.3.2-7")
    end

    it "fails when <processing-meta> is absent" do
      expect(ids("<front/>")).to include("iso-gdg-4.3.2-7")
    end

    it "passes a non-empty edition" do
      expect(ids(format(meta, "<meta-value>2.1</meta-value>")))
        .not_to include("iso-gdg-4.3.2-7")
    end
  end

  describe "namespace URIs, not document prefixes" do
    it "recognises TBX under a non-tbx prefix (9.2.1-1)" do
      xml = '<standard xmlns:t="urn:iso:std:iso:30042:ed-1"><t:termEntry>' \
            '<t:langSet xml:lang="en"><t:tig><t:term>x</t:term></t:tig>' \
            "<t:definition>d</t:definition></t:langSet></t:termEntry></standard>"
      ids = described_class.new.validate(xml).errors.map(&:rule_id)
      expect(ids).not_to include("iso-gdg-9.2.1-1")
    end

    it "recognises MathML under a non-mml prefix (7.4-1)" do
      xml = %(<inline-formula xmlns:math="http://www.w3.org/1998/Math/MathML"><math:math><math:mi>x</math:mi>) +
        "</math:math></inline-formula>"
      expect(described_class.new.validate(xml).errors.map(&:rule_id))
        .not_to include("iso-gdg-7.4-1")
    end

    it "reads xlink:href under a non-xlink prefix (5.10-2)" do
      xml = %(<standard xmlns:x="http://www.w3.org/1999/xlink"><graphic x:href="a.png"/></standard>)
      expect(described_class.new.validate(xml).errors.map(&:rule_id))
        .to include("iso-gdg-5.10-2")
    end
  end

  describe "legend titles (8.3-2, 7.3-2)" do
    it "accepts 'Key' anywhere in a figure legend title" do
      expect(ids(legend("Figure Key"))).not_to include("iso-gdg-8.3-2")
    end

    it "accepts 'where' anywhere in a formula legend title" do
      expect(ids(legend("Variables where", tag: "disp-formula")))
        .not_to include("iso-gdg-7.3-2")
    end

    it "still fails a legend title without the word" do
      expect(ids(legend("Legend"))).to include("iso-gdg-8.3-2")
    end
  end

  describe "normative reference <std-id> (4.4.2-5)" do
    def norm(std_ids)
      "<ref-list content-type=\"norm-refs\"><ref><std>#{std_ids}" \
        "<std-ref>ISO 1</std-ref><title>T</title></std></ref></ref-list>"
    end

    it "fails when the two attributes sit on different <std-id> elements" do
      split = %(<std-id std-id-link-type="urn">x</std-id>) +
        %(<std-id std-id-type="dated">y</std-id>)
      expect(ids(norm(split))).to include("iso-gdg-4.4.2-5")
    end

    it "passes when both are on one <std-id>" do
      one = %(<std-id std-id-link-type="urn" std-id-type="dated">x</std-id>)
      expect(ids(norm(one))).not_to include("iso-gdg-4.4.2-5")
    end
  end

  describe "graphic references (5.10-3)" do
    def front(originator)
      "<front><std-meta><originator>#{originator}</originator></std-meta></front>"
    end

    it "applies the ISO no-slash rule to data: references" do
      xml = "#{front('ISO')}<graphic xlink:href=\"data:image/png;base64,AAAA\"/>"
      expect(ids(xml)).to include("iso-gdg-5.10-3")
    end

    it "fails an empty IEC reference" do
      expect(ids("#{front('IEC')}<graphic xlink:href=\"\"/>"))
        .to include("iso-gdg-5.10-3")
    end

    it "passes an IEC reference carrying a folder" do
      expect(ids("#{front('IEC')}<graphic xlink:href=\"a/b\"/>"))
        .not_to include("iso-gdg-5.10-3")
    end
  end

  describe "subclause label (4.4.2-1)" do
    it "does not exempt an unlabelled intro section with subclauses" do
      xml = %(<front><sec sec-type="intro"><title>Introduction</title>) +
        "<sec><title>X</title></sec></sec></front>"
      expect(ids(xml)).to include("iso-gdg-4.4.2-1")
    end
  end

  describe "terms clause containment (9.1-1)" do
    it "does not flag an entry nested below a child section" do
      xml = %(<body><sec sec-type="terms"><sec><term-sec><tbx:termEntry/>) +
        "</term-sec></sec></sec></body>"
      expect(ids(xml)).not_to include("iso-gdg-9.1-1")
    end

    it "flags an entry that is a direct child of a child section" do
      xml = %(<body><sec sec-type="terms"><sec><tbx:termEntry/></sec></sec></body>)
      expect(ids(xml)).to include("iso-gdg-9.1-1")
    end
  end
end
