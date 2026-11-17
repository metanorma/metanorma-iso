# frozen_string_literal: true

RSpec.describe Metanorma::Iso::Sts do
  let(:input) { File.read(FIXTURES_ROOT.join("sample.xml")) }

  describe ".convert" do
    it "returns an ISO NISO STS XML string" do
      output = described_class.convert(input)
      expect(output).to include("<standard")
      # The NISO STS XSD pins the root dtd-version to the fixed "1.0".
      expect(output).to include('dtd-version="1.0"')
      expect(output).to include("<processing-meta")
      # ISO flavor front matter is <iso-meta>; its <std-ident>
      # decomposes the identifier into originator / doc-number.
      expect(output).to include("<iso-meta>")
      expect(output).to include("<originator>ISO</originator>")
      expect(output).to include("<doc-number>7</doc-number>")
    end

    it "records the publisher copyright on iso-meta" do
      output = described_class.convert(input)
      expect(output).to include("<copyright-holder>International " \
                                "Organization of Legal Metrology</copyright-holder>")
    end

    it "transforms <clause> → <sec> with title" do
      output = described_class.convert(input)
      expect(output).to include("<sec")
      expect(output).to include("<title>Scope</title>")
    end

    it "transforms <ul> → <list list-type='bullet'>" do
      output = described_class.convert(input)
      expect(output).to match(/<list[^>]*list-type="bullet"/)
      expect(output).to include("<list-item>")
    end
  end

  describe ".validate" do
    it "passes for a well-formed OIML STS document" do
      valid_sts = described_class.convert(input)
      report = described_class.validate(valid_sts)
      expect(report).to be_valid
    end

    it "fails when root is not <standard>" do
      report = described_class.validate("<other/>")
      expect(report).not_to be_valid
      expect(report.errors.first.rule_id).to eq("oiml-x999-root-element")
    end
  end
end
