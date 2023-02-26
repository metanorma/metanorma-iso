require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.default_cassette_options = {
    clean_outdated_http_interactions: true,
    re_record_interval: 1512000,
    record: :once,
  }
end

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
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r{ src="cid:[^.]+.gif"}, ' src="_.gif"')
    .gsub(%r{ src='cid:[^.]+.gif'}, ' src="_.gif"')
end

def metadata(hash)
  hash.sort.to_h.delete_if do |_, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def xmlpp(xml)
  c = HTMLEntities.new
  xml &&= xml.split(/(&\S+?;)/).map do |n|
    if /^&\S+?;$/.match?(n)
      c.encode(c.decode(n), :hexadecimal)
    else n
    end
  end.join
  xsl = <<~XSL
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
      <xsl:strip-space elements="*"/>
      <xsl:template match="/">
        <xsl:copy-of select="."/>
      </xsl:template>
    </xsl:stylesheet>
  XSL
  ret = Nokogiri::XSLT(xsl).transform(Nokogiri::XML(xml, &:noblanks))
    .to_xml(indent: 2, encoding: "UTF-8")
    .gsub(%r{<fetched>20[0-9-]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
  HTMLEntities.new.decode(ret)
end

ASCIIDOC_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib:

HDR

AMD_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib:
  :doctype: amendment

HDR

ISOBIB_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib-cache:

HDR

FLUSH_CACHE_ISOBIB_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :flush-caches:

HDR

CACHED_ISOBIB_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:

HDR

LOCAL_CACHED_ISOBIB_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :local-cache:

HDR

VALIDATING_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
HDR

ASCIIDOCTOR_ISO_DIR = Pathname
  .new(File.dirname(__FILE__)) / "../lib/metanorma/iso"

BOILERPLATE =
  HTMLEntities.new.decode(
    File.read(ASCIIDOCTOR_ISO_DIR / "boilerplate.xml", encoding: "utf-8")
      .gsub(/\{\{ agency \}\}/, "ISO")
  .gsub(/\{\{ docyear \}\}/, Date.today.year.to_s)
      .gsub(/\{% if unpublished %\}.*?\{% endif %\}/m, "")
      .gsub(/\{% if stage_int >= 40 %\}(.*?)\{% endif %\}/m, "\\1")
      .gsub(/(?<=\p{Alnum})'(?=\p{Alpha})/, "’"),
  )

BOILERPLATE_FR =
  HTMLEntities.new.decode(
    File.read(ASCIIDOCTOR_ISO_DIR / "boilerplate-fr.xml", encoding: "utf-8")
    .gsub(/\{\{ agency \}\}/, "ISO")
    .gsub(/\{\{ docyear \}\}/, Date.today.year.to_s)
    .gsub(/\{% if unpublished %\}.*?\{% endif %\}/m, "")
      .gsub(/\{% if stage_int >= 40 %\}(.*?)\{% endif %\}/m, "\\1")
    .gsub(/(?<=\p{Alnum})'(?=\p{Alpha})/, "’"),
  )

BLANK_HDR1 = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <iso-standard xmlns="https://www.metanorma.org/ns/iso" type="semantic" version="#{Metanorma::ISO::VERSION}">
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
      <language>en</language>
      <script>Latn</script>
      <status>
        <stage>60</stage>
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
        <editorialgroup>
          <agency>ISO</agency>
        </editorialgroup>
        <approvalgroup>
          <agency>ISO</agency>
        </approvalgroup>
        <stagename>International Standard</stagename>
      </ext>
    </bibdata>
        <metanorma-extension>
    <presentation-metadata>
      <name>TOC Heading Levels</name>
      <value>3</value>
    </presentation-metadata>
    <presentation-metadata>
      <name>HTML TOC Heading Levels</name>
      <value>2</value>
    </presentation-metadata>
    <presentation-metadata>
      <name>DOC TOC Heading Levels</name>
      <value>3</value>
    </presentation-metadata>
  </metanorma-extension>
HDR

BLANK_HDR = <<~"HDR".freeze
  #{BLANK_HDR1}
  #{BOILERPLATE}
HDR

BLANK_HDR_FR = <<~"HDR".freeze
  #{BLANK_HDR1.sub(%r{<language>en</language>}, '<language>fr</language>')}
  #{BOILERPLATE_FR}
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
  allow(::Mn2pdf).to receive(:convert) do |url, output,|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
  end
end

def mock_sts
  allow(::Mn2sts).to receive(:convert) do |url, output,|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
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
