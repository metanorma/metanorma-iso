# frozen_string_literal: true

RSpec.describe Metanorma::Iso::Sts do
  let(:input) { File.read(FIXTURES_ROOT.join("sample.xml")) }

  describe ".convert" do
    it "returns an OIML NISO STS XML string" do
      output = described_class.convert(input)
      expect(output).to include("<standard")
      expect(output).to include('dtd-version="1.2"')
      expect(output).to include("<processing-meta")
      # NISO STS <std-ident>: the OIML identifier decomposed into
      # originator / doc-type / doc-number.
      expect(output).to include("<originator>OIML</originator>")
      expect(output).to include("<doc-type>r</doc-type>")
      expect(output).to include("<doc-number>7</doc-number>")
    end

    it "records the OIML series letter in <custom-meta>" do
      output = described_class.convert(input)
      expect(output).to include("oiml-doc-series")
      expect(output).to include("<meta-value>R</meta-value>")
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
