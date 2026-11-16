# frozen_string_literal: true

require "nokogiri"
require "tempfile"
require_relative "../../../spec_helper"

# Regression specs for the NISO STS output sanitizers: each nested
# describe pins one violation class found in the mnconvert NISO STS
# output for the ISO 19135 delivery, verified against the NISO STS
# extended-1 MathML3 XSD.
RSpec.describe Metanorma::Iso::Sts::OutputSanitizer do
  subject(:sanitized) { described_class.sanitize(xml) }

  let(:doc) { Nokogiri::XML(sanitized) }

  let(:warning_splice) do
    <<~TEXT
      WARNING! There are unprocessed elements in bibdata:
      ===================================
      ===================================
    TEXT
  end

  def sanitize_into_file(content)
    file = Tempfile.new(["document", ".sts.xml"])
    File.write(file.path, content)
    described_class.sanitize_file(file.path)
    file
  end

  def leaked_meta_value_at(document)
    document.at_xpath(
      "//std-meta/custom-meta-group/custom-meta[meta-name='iso-cen-parallel']/meta-value",
    )
  end

  describe "front leak sanitizer (stray text + undeclared metadata)" do
    let(:xml) do
      <<~XML
        <standard xmlns:xlink="http://www.w3.org/1999/xlink">
          <front>
            <std-meta>
              <std-ident>
                <originator>ISO</originator>
                <doc-type>IS</doc-type>
                <doc-number>19135</doc-number>
              </std-ident>
              <content-language>en</content-language>
              <custom-meta-group>
                <custom-meta>
                  <meta-name>flavor</meta-name>
                  <meta-value>iso</meta-value>
                </custom-meta>
              </custom-meta-group>#{warning_splice}<iso-cen-parallel>true</iso-cen-parallel>#{warning_splice}
            </std-meta>
          </front>
          <body><sec id="sec_1"><p>Text.</p></sec></body>
        </standard>
      XML
    end

    it "removes the spliced warning text from std-meta" do
      expect(doc.xpath("//std-meta/text()[normalize-space() != '']")).to be_empty
    end

    it "does not retain the mnconvert warning" do
      expect(sanitized).not_to include("WARNING!")
    end

    it "migrates the leaked element value into custom-meta" do
      expect(leaked_meta_value_at(doc).text).to eq("true")
    end

    it "removes the leaked element itself" do
      expect(doc.xpath("//iso-cen-parallel")).to be_empty
    end

    it "appends the migrated entry after existing custom-meta" do
      names = doc.xpath("//std-meta/custom-meta-group/custom-meta/meta-name")
        .map(&:text)
      expect(names).to eq(%w[flavor iso-cen-parallel])
    end

    it "leaves declared std-meta children untouched" do
      expect(doc.at_xpath("//std-meta/std-ident/doc-number").text)
        .to eq("19135")
    end

    it "creates a custom-meta-group when the front has none" do
      xml_no_group = xml.sub(%r{<custom-meta-group>.*</custom-meta-group>}m, "")
      expect(leaked_meta_value_at(Nokogiri::XML(described_class.sanitize(xml_no_group))))
        .not_to be_nil
    end
  end

  describe "inline identifier sanitizer (undeclared inline element)" do
    let(:xml) do
      <<~XML
        <standard xmlns:xlink="http://www.w3.org/1999/xlink">
          <body>
            <sec id="sec_1">
              <p>The URI <identifier>https://geodetic.isotc211.org</identifier> is unique.</p>
              <p>The URN namespace <identifier>urn:isbn</identifier> is registered.</p>
            </sec>
          </body>
        </standard>
      XML
    end

    it "maps p-level identifiers to named-content with content-type" do
      expect(doc.xpath("//p/named-content[@content-type='identifier']").size)
        .to eq(2)
    end

    it "preserves the identifier text verbatim" do
      expect(doc.xpath("//p/named-content").map(&:text))
        .to eq(["https://geodetic.isotc211.org", "urn:isbn"])
    end

    it "removes the undeclared identifier elements" do
      expect(doc.xpath("//identifier")).to be_empty
    end
  end

  describe "unique id sanitizer (xs:ID uniqueness)" do
    let(:xml) do
      <<~XML
        <standard xmlns:xlink="http://www.w3.org/1999/xlink">
          <body>
            <sec id="sec_scope" sec-type="scope"><label>C.3.2</label><p>One.</p></sec>
            <sec id="sec_intro"><p>Intro.</p></sec>
            <sec id="sec_scope" sec-type="scope"><label>D.1</label><p>Two.</p></sec>
            <sec id="sec_scope_1"><p>Unrelated pre-existing id.</p></sec>
          </body>
        </standard>
      XML
    end

    it "keeps the first occurrence under the original id" do
      first = doc.xpath("//sec[@id='sec_scope']")
      expect(first.at_xpath("label").text).to eq("C.3.2")
    end

    it "renames later occurrences, skipping taken suffixes" do
      expect(doc.xpath("//sec[@id='sec_scope_2']/label").text).to eq("D.1")
    end

    it "renames exactly one occurrence" do
      expect(doc.xpath("//sec[@id='sec_scope']").size).to eq(1)
    end

    it "leaves unique ids untouched" do
      expect(doc.xpath("//sec[@id='sec_intro']")).not_to be_empty
    end

    it "leaves non-id attributes untouched" do
      expect(doc.xpath("//sec[@sec-type='scope']").size).to eq(2)
    end
  end

  describe "pipeline behaviour" do
    let(:xml) do
      <<~XML
        <standard xmlns:xlink="http://www.w3.org/1999/xlink">
          <front>
            <std-meta>
              <doc-number>19135</doc-number>
              <custom-meta-group/>
              <iso-cen-parallel>true</iso-cen-parallel>
            </std-meta>
          </front>
          <body>
            <sec id="sec_scope"><p>See <identifier>/req/one</identifier>.</p></sec>
            <sec id="sec_scope"><p>Two.</p></sec>
          </body>
        </standard>
      XML
    end

    it "migrates the front leak and strips stray text in one pass" do
      expect(doc.xpath("//std-meta/iso-cen-parallel")).to be_empty
    end

    it "maps the inline identifier in one pass" do
      named = doc.at_xpath("//p/named-content[@content-type='identifier']")
      expect(named.text).to eq("/req/one")
    end

    it "uniquifies the colliding section ids in one pass" do
      ids = doc.xpath("//sec/@id").map(&:text)
      expect(ids).to eq(%w[sec_scope sec_scope_1])
    end

    it "is idempotent" do
      expect(described_class.sanitize(sanitized)).to eq(sanitized)
    end

    it "sanitizes a file in place" do
      file = sanitize_into_file(xml)
      expect(Nokogiri::XML(File.read(file.path)).xpath("//identifier"))
        .to be_empty
      file.close
      file.unlink
    end
  end
end
