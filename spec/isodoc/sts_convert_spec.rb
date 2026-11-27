# frozen_string_literal: true

require "tmpdir"
require "metanorma/iso/sts/output_sanitizer"
require "spec_helper"

# The mnconvert binary writes its NISO STS output before self-validating
# it, so legacy Metanorma constructs make it reject the file it just
# wrote. The STS writer must complete that emission through the output
# sanitizer instead of abandoning the leg.
RSpec.describe IsoDoc do
  let(:out_path) { File.join(Dir.tmpdir, "sts-convert-spec.sts.xml") }
  let(:original_convert) { MnConvert.method(:convert) }
  let(:converter) { IsoDoc::Iso::StsConvert.new({}) }

  let(:raw_output) do
    <<~XML
      <standard xmlns:xlink="http://www.w3.org/1999/xlink">
        <front>
          <std-meta>
            <doc-number>19135</doc-number>
            <iso-cen-parallel>true</iso-cen-parallel>
          </std-meta>
        </front>
        <body>
          <sec id="sec_scope"><p>A <identifier>/req/one</identifier>.</p></sec>
          <sec id="sec_scope"><p>B.</p></sec>
        </body>
      </standard>
    XML
  end

  def stub_rejected_emission
    stub_output = raw_output
    MnConvert.define_singleton_method(:convert) do |*_args|
      File.write(_args[1][:output_file], stub_output)
      raise "RuntimeError: [mnconvert] self-validation rejected the output"
    end
  end

  def stub_crash_before_writing
    MnConvert.define_singleton_method(:convert) do |*_args|
      raise "RuntimeError: [mnconvert] crashed before writing"
    end
  end

  before do
    original_convert
    stub_rejected_emission
    allow(converter).to receive(:convert_init)
      .and_return([nil, "document", nil])
    allow(FileUtils).to receive(:rm_rf)
  end

  after do
    restored = original_convert
    MnConvert.define_singleton_method(:convert) do |input_file, opts = {}|
      restored.call(input_file, opts)
    end
    FileUtils.rm_f(out_path)
  end

  def sanitized_document
    Nokogiri::XML(File.read(out_path))
  end

  it "completes an emission that mnconvert wrote and then rejected" do
    converter.convert("/tmp/fake.adoc", "<adoc/>", false, out_path)
    expect(sanitized_document.xpath("//iso-cen-parallel")).to be_empty
  end

  it "sanitizes the inline markup of the written artifact" do
    converter.convert("/tmp/fake.adoc", "<adoc/>", false, out_path)
    expect(
      sanitized_document
        .xpath("//p/named-content[@content-type='identifier']").size,
    ).to eq(1)
  end

  it "uniquifies the generated ids of the written artifact" do
    converter.convert("/tmp/fake.adoc", "<adoc/>", false, out_path)
    expect(sanitized_document.xpath("//sec/@id").map(&:text).uniq.size)
      .to eq(2)
  end

  # <processing-meta> is required per the IEC/ISO Coding Guidelines ed. 2.1
  # 4.3.2 for every NISO STS document. The IEC and ISO +:sts+ leg runs
  # through this converter, not the native driver, so the declaration
  # must be written here as well.
  it "declares the coding profile in processing-meta (guidelines 4.3.2)" do
    converter.convert("/tmp/fake.adoc", "<adoc/>", false, out_path)
    expect(processing_meta_profile).to eq(expected_coding_profile)
  end

  def expected_coding_profile
    { "tagset-family" => "sts", "base-tagset" => "interchange",
      "table-model" => "xhtml", "mathml-version" => "3.0",
      "math-representation" => "mathml", "terminology-model" => "tbx",
      "edition" => "2.1" }
  end

  def processing_meta_profile
    meta = sanitized_document.at_xpath("/standard/processing-meta")
    return nil unless meta

    edition = meta.at_xpath(
      "custom-meta-group/custom-meta" \
      "[meta-name='iec_iso_coding_guidelines_edition']/meta-value",
    )&.text
    meta.attributes.transform_values(&:value).merge("edition" => edition)
  end

  it "re-raises when mnconvert produced no usable artifact" do
    stub_crash_before_writing
    expect do
      converter.convert("/tmp/fake.adoc", "<adoc/>", false, out_path)
    end.to raise_error(RuntimeError, /crashed before writing/)
  end

  def stub_accepted_emission
    stub_output = raw_output
    MnConvert.define_singleton_method(:convert) do |*_args|
      File.write(_args[1][:output_file], stub_output)
    end
  end

  it "sanitizes an accepted mnconvert emission the same way" do
    stub_accepted_emission
    converter.convert("/tmp/fake.adoc", "<adoc/>", false, out_path)
    expect(sanitized_document.xpath("//identifier")).to be_empty
  end
end
