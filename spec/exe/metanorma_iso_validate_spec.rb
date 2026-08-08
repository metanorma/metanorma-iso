require "spec_helper"
require "open3"
require "tmpdir"

RSpec.describe "metanorma-iso-validate CLI" do
  let(:project_dir) { File.expand_path("../..", __dir__) }
  let(:exe) { File.expand_path("exe/metanorma-iso-validate", project_dir) }
  let(:minimal_xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
        </bibdata>
        <preface>
          <foreword id="fw"><p>foreword</p></foreword>
        </preface>
        <sections>
          <clause type="scope" id="scope"><title>Scope</title></clause>
          <terms id="terms"><title>Terms</title></terms>
          <clause id="c1"><title>Body</title></clause>
        </sections>
        <bibliography>
          <references normative="true"><title>Norm Refs</title></references>
          <references normative="false"><title>Bibliography</title></references>
        </bibliography>
      </metanorma>
    XML
  end

  around do |ex|
    Dir.mktmpdir("mn-iso-cli-") do |dir|
      @file = File.join(dir, "doc.xml")
      File.write(@file, minimal_xml)
      ex.run
    end
  end

  def run_cli(*args)
    stdout, status = Open3.capture2({ "BUNDLE_GEMFILE" => ENV["BUNDLE_GEMFILE"] },
                                    "bundle", "exec", "ruby", exe, *args, @file)
    [stdout, status]
  end

  it "exits 0 for a valid document" do
    _out, status = run_cli
    expect(status.exitstatus).to eq(0)
  end

  it "prints text output by default" do
    out, _status = run_cli
    expect(out).to include("findings")
  end

  it "prints JSON when --format json" do
    out, _status = run_cli("--format", "json")
    parsed = JSON.parse(out)
    expect(parsed).to be_a(Hash)
    expect(parsed["document"]).to eq(@file)
  end

  it "prints YAML when --format yaml" do
    out, _status = run_cli("--format", "yaml")
    parsed = YAML.safe_load(out)
    expect(parsed).to be_a(Hash)
  end

  it "writes to --output file" do
    out_path = "#{@file}.out"
    _out, _status = run_cli("--output", out_path)
    expect(File.exist?(out_path)).to be(true)
    expect(File.read(out_path)).to include("findings")
  end

  it "exits 1 for an invalid document" do
    File.write(@file, minimal_xml.sub("<terms id=\"terms\">", "<terms id=\"dup\">")
                                  .sub("<clause type=\"scope\"", "<terms id=\"dup\">"))
    # Replacing produces invalid XML; use a simpler invalid case:
    File.write(@file, <<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
        </bibdata>
      </metanorma>
    XML
    _out, status = run_cli
    expect(status.exitstatus).to eq(1)
  end
end
