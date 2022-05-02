require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "maps styles for DIS" do
    IsoDoc::Iso::WordConvert
      .new({})
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>30</stage></status>
          </bibdata>
          <sections>
          <terms id="A">
            <term id="B">
            <preferred><expression><name>First</name></expression></preferred>
            <admitted><expression><name>Second</name></expression></admitted>
            </term>
          </terms>
          </sections>
        </iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html).to include 'class="AltTerms"'
    expect(html).not_to include 'class="AdmittedTerm"'

    IsoDoc::Iso::WordConvert
      .new({})
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>50</stage></status>
          </bibdata>
          <sections>
          <terms id="A">
            <term id="B">
            <preferred><expression><name>First</name></expression></preferred>
            <admitted><expression><name>Second</name></expression></admitted>
            </term>
          </terms>
          </sections>
        </iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html).not_to include 'class="AltTerms"'
    expect(html).to include 'class="AdmittedTerm"'
  end
end
