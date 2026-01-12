require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-iso"
require "rspec/matchers"
require "equivalent-xml"
require "metanorma"
require "metanorma/iso"
require "iev"
require "canon"
require "relaton_iso"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  #   config.around do |example|
  #     Dir.mktmpdir("rspec-") do |dir|
  #       tmp_assets = File.join(dir, "spec/assets/")
  #       FileUtils.mkdir_p tmp_assets
  #       FileUtils.cp_r Dir.glob("spec/assets/*"), tmp_assets
  #       Dir.chdir(dir) { example.run }
  #     end
  #   end
end

def presxml_options
  { semanticxmlinsert: "false" }
end

def strip_guid(xml)
  xml.gsub(%r{ id=['"]_[^"']+['"]}, ' id="_"')
    .gsub(%r{ id="(fn:|ftn)_[^"]+"}, ' id="fn:_"')
    .gsub(%r{ semx-id="[^"]*"}, '')
    .gsub(%r{ name="_[^"]+"}, ' name="_"')
    .gsub(%r{ from="_[^"]+"}, ' from="_"')
    .gsub(%r{ to="_[^"]+"}, ' to="_"')
    .gsub(%r{ original-id="_[^"]+"}, ' original-id="_"')
    .gsub(%r{ original-reference="_[^"]+"}, ' original-reference="_"')
    .gsub(%r{ href="#_[^"]+"}, ' href="#_"')
    .gsub(%r{ href="#(fn:|ftn)_[^"]+"}, ' href="#fn:_"')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r{ source="_[^"]+"}, ' source="_"')
    .gsub(%r{ container="_[^"]+"}, ' container="_"')
    .gsub(%r{ src="cid:[^.]+.gif"}, ' src="_.gif"')
    .gsub(%r{ src='cid:[^.]+.gif'}, ' src="_.gif"')
    .gsub(%r{<fetched>20[0-9-]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
    .gsub(%r[ _Ref\d+{8,10}], " _Ref")
    .gsub(%r[:_Ref\d+{8,10}], ":_Ref")
    .gsub(%r( bibitemid="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), ' bibitemid="_"')
end

def metadata(hash)
  hash.sort.to_h.delete_if do |_, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

ASCIIDOC_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib:

HDR

AMD_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib:
  :doctype: amendment

HDR

ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib-cache:

HDR

FLUSH_CACHE_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :flush-caches:

HDR

CACHED_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:

HDR

LOCAL_CACHED_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :local-cache: spec/relatondb

HDR

VALIDATING_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
HDR

ASCIIDOCTOR_ISO_DIR = Pathname
  .new(File.dirname(__FILE__)) / "../lib/metanorma/iso"

def boilerplate_read(file, xmldoc)
  conv = Metanorma::Iso::Converter.new(:iso, {})
  conv.init(Asciidoctor::Document.new([]))
  x = conv.boilerplate_isodoc(xmldoc).populate_template(file, nil)
  ret = conv.boilerplate_file_restructure(x)
  ret.to_xml(encoding: "UTF-8", indent: 2,
             save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    .gsub(/<(\/)?sections>/, "<\\1boilerplate>")
    .gsub(/ id="_[^"]+"/, " id='_'")
end

def boilerplate(xmldoc, lang: "en")
  lang = if lang == "en" then "" else "-#{lang}" end
  file = File.join(File.dirname(__FILE__), "..", "lib", "metanorma", "iso",
                   "boilerplate#{lang}.adoc")
  ret = Nokogiri::XML(boilerplate_read(
    File.read(file, encoding: "utf-8"), xmldoc
  ))
  ret.xpath("//passthrough").each(&:remove)
  strip_guid(ret.root.to_xml(encoding: "UTF-8", indent: 2,
                             save_with: Nokogiri::XML::Node::SaveOptions::AS_XML))
end

BLANK_HDR1 = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Iso::VERSION}" flavor="iso">
    <bibdata type="standard">
      <contributor>
        <role type="author"/>
        <organization>
          <name>International Organization for Standardization</name>
          <abbreviation>ISO</abbreviation>
        </organization>
      </contributor>
      <contributor>
        <role type="publisher"/>
        <organization>
          <name>International Organization for Standardization</name>
          <abbreviation>ISO</abbreviation>
        </organization>
      </contributor>
      <contributor>
      <role type="authorizer"><description>Agency</description></role>
      <organization>
        <name>International Organization for Standardization</name>
        <abbreviation>ISO</abbreviation>
      </organization>
    </contributor>
      <language>en</language>
      <script>Latn</script>
      <status>
        <stage abbreviation="IS">60</stage>
        <substage>60</substage>
      </status>
      <copyright>
        <from>#{Time.new.year}</from>
        <owner>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </owner>
      </copyright>
      <ext>
        <doctype>standard</doctype>
        <flavor>iso</flavor>
        <stagename abbreviation="IS">International Standard</stagename>
      </ext>
    </bibdata>
        <metanorma-extension>
         <semantic-metadata>
         <stage-published>true</stage-published>
      </semantic-metadata>
    <presentation-metadata>
      <document-scheme>2024</document-scheme>
      <toc-heading-levels>2</toc-heading-levels>
      <html-toc-heading-levels>2</html-toc-heading-levels>
      <doc-toc-heading-levels>3</doc-toc-heading-levels>
      <pdf-toc-heading-levels>3</pdf-toc-heading-levels>
    </presentation-metadata>
  </metanorma-extension>
HDR

BLANK_HDR = <<~"HDR".freeze
  #{BLANK_HDR1}
  #{boilerplate(Nokogiri::XML("#{BLANK_HDR1}</metanorma>"))}
HDR

BLANK_HDR_FR = <<~"HDR".freeze
  #{BLANK_HDR1.sub(%r{<language>en</language>}, '<language>fr</language>')}
  #{boilerplate(Nokogiri::XML("#{BLANK_HDR1.sub(%r{<language>en</language>}, '<language>fr</language>')}</metanorma>"), lang: 'fr')}
HDR

TERM_BOILERPLATE = <<~TERM.freeze
  <p id="_">For the purposes of this document,
    the following terms and definitions apply.</p>
  <p id="_">ISO and IEC maintain terminology databases for use in
    standardization at the following addresses:</p>

  <ul id="_">
    <li>
      <p id="_">ISO Online browsing platform: available at
        <link target="https://www.iso.org/obp"/></p>
    </li>
    <li>
      <p id="_">IEC Electropedia: available at
        <link target="https://www.electropedia.org"/>
      </p>
    </li>
  </ul>
TERM

HTML_HDR = <<~HDR.freeze
  <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
    <head/>
    <body lang="en">
      <div class="title-section">
        <p>&#160;</p>
      </div>
      <br/>
      <div class="prefatory-section">
        <p>&#160;</p>
      </div>
      <br/>
      <div class="main-section">
            <br/>
      <div class="TOC" id="_">
        <h1 class="IntroTitle">Contents</h1>
      </div>
HDR

WORD_HDR = <<~HDR.freeze
  <html xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
      <title>test</title>
    </head>
    <body lang="EN-US" link="blue" vlink="#954F72">
      <div class="WordSection1">
        <p>&#160;</p>
      </div>
      <p><br clear="all" class="section"/></p>
      <div class="WordSection2">
        <p>&#160;</p>
      </div>
      <p><br clear="all" class="section"/></p>
      <div class="WordSection3">
HDR

OPTIONS = [backend: :iso, header_footer: true].freeze

def mock_pdf
  allow(Mn2pdf).to receive(:convert) do |url, output,|
    FileUtils.cp(url.delete('"'), output.delete('"'))
  end
end

def mock_sts
  allow(Mn2sts).to receive(:convert) do |url, output,|
    FileUtils.cp(url.delete('"'), output.delete('"'))
  end
end

private

def get_xml(search, code, opts)
  c = code.gsub(%r{[/\s:-]}, "_").sub(%r{_+$}, "").downcase
  o = opts.keys.join "_"
  file = "spec/examples/#{[c, o].join '_'}.xml"
  if File.exist? file
    File.read file
  else
    result = search.call(code)
    hit = result&.first&.first
    xml = hit.to_xml nil, opts
    File.write file, xml
    xml
  end
end

def mock_open_uri(code)
  expect(Iev).to receive(:get).with(code, "en") do |m, *args|
    file = "spec/examples/#{code.tr('-', '_')}.html"
    File.write file, m.call(*args).read unless File.exist? file
    File.read file
  end.at_least :once
end
