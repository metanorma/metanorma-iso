require "spec_helper"

# metanorma-iso#1897: the ISO templates read plain bibdata values through the
# `bibdata.*` Liquid object (isodoc#784) instead of the flat metadata keys.
# Each changed field must render the same output as the flat key.
RSpec.describe IsoDoc::Iso::Metadata, "bibdata.* Liquid paths in templates" do
  docyear = '{{ bibdata.copyright | map: "from" | compact | first }}'
  ics_codes = '{% assign ics_codes = bibdata.ext.ics | map: "code" | compact %}'

  def lib_dir(*path)
    File.join(File.dirname(__FILE__), "..", "..", "lib", *path)
  end

  def template(file)
    File.read(lib_dir("isodoc", "iso", "html", file), encoding: "UTF-8")
  end

  def ics_xml(ics)
    { true => "<ics><code>67.060</code></ics><ics><code>01.040</code></ics>",
      false => "",
      one: "<ics><code>67.060</code><text>Cereals</text></ics>",
      nocode: "<ics><text>Cereals</text></ics>" }[ics]
  end

  def copyright_xml(copyright)
    owner = "<owner><organization><abbreviation>ISO</abbreviation>" \
            "</organization></owner>"
    { one: "<copyright><from>2016</from>#{owner}</copyright>",
      two: "<copyright><from>2016</from>#{owner}</copyright>" \
           "<copyright><from>2017</from>#{owner}</copyright>",
      first_no_from: "<copyright>#{owner}</copyright>" \
                     "<copyright><from>2017</from>#{owner}</copyright>",
      none: "" }[copyright]
  end

  def ext_xml(ics, fast_track)
    ret = ics_xml(ics)
    fast_track.nil? or ret += "<fast-track>#{fast_track}</fast-track>"
    ret
  end

  def undated_xml(undated)
    undated or return ""
    '<docidentifier type="iso-undated">ISO 17301-1</docidentifier>'
  end

  def bibdata_xml(ics: true, fast_track: true, copyright: :one, undated: true)
    <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
          <title language="en" type="title-main">Main title</title>
          <docidentifier type="ISO" primary="true">ISO 17301-1:2016</docidentifier>
          #{undated_xml(undated)}
          <docidentifier type="iso-reference">ISO 17301-1:2016(E)</docidentifier>
          <docnumber>17301</docnumber>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <language>en</language>
          <script>Latn</script>
          <status><stage abbreviation="IS">60</stage><substage>60</substage></status>
          #{copyright_xml(copyright)}
          <ext>
            <doctype>international-standard</doctype>
            #{ext_xml(ics, fast_track)}
            <structuredidentifier>
              <project-number part="1">ISO 17301</project-number>
            </structuredidentifier>
          </ext>
        </bibdata>
      </iso-standard>
    INPUT
  end

  def converter(klass, **opts)
    c = klass.new({})
    c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    c.info(Nokogiri::XML(bibdata_xml(**opts)), nil)
    c
  end

  def render(conv, template)
    conv.populate_template(template, nil)
  end

  # Each variant is one bibdata shape: the bibdata path must render the same
  # output as the flat key for each of them.
  variants = [
    {},
    { ics: false, fast_track: nil, copyright: :none, undated: false },
    { ics: :one, fast_track: "false", copyright: :two },
    { ics: :nocode, copyright: :first_no_from },
  ]

  {
    "docyear" => ["{{ docyear }}", docyear],
    "ics" => ["{{ ics }}", "#{ics_codes}{{ ics_codes | join: \", \" }}"],
    "ics test" => ["{% if ics %}Y{% endif %}",
                   "#{ics_codes}{% if ics_codes.size > 0 %}Y{% endif %}"],
    "docnumber_undated" =>
      ["{{ docnumber_undated }}",
       '{%- assign undated = bibdata.docidentifier | where: "type", ' \
       '"iso-undated" | first -%}{{ undated.content }}'],
    "fast_track" => ['{%if fast_track == "true" %}Y{% endif %}',
                     "{% if bibdata.ext.fast_track == true %}Y{% endif %}"],
  }.each do |name, (flat, path)|
    it "renders #{name} from bibdata as the flat key does" do
      expect(render(converter(IsoDoc::Iso::WordConvert), flat)).not_to be_empty
      variants.each do |v|
        c = converter(IsoDoc::Iso::WordConvert, **v)
        expect(render(c, path)).to eq(render(c, flat)), "variant #{v}"
      end
    end
  end

  %w(header.html header-dis.html).each do |file|
    it "uses bibdata paths in the Word header #{file}" do
      t = template(file)
      expect(t).not_to match(/\{\{\s*(docyear|ics)\s*\}\}|\{%\s*if ics\s*%\}/)
      out = render(converter(IsoDoc::Iso::WordConvert), t)
      expect(out).to include("ISO&nbsp;2016&nbsp;– All rights reserved")
      expect(out).to include("ICS 67.060, 01.040")
      out = render(converter(IsoDoc::Iso::WordConvert, ics: :nocode), t)
      expect(out).not_to include("ICS ")
    end
  end

  %w(html_iso_titlepage.html word_iso_titlepage.html
     word_iso_titlepage-dis.html word_iso_titlepage-prf.html).each do |file|
    it "uses bibdata paths in the title page #{file}" do
      t = template(file)
      expect(t).not_to match(
        /\{\{\s*(ics|docnumber_undated)\s*\}\}|\{%\s*if (ics|fast_track)\b(?!_)/,
      )
      klass = file.start_with?("html") ? IsoDoc::Iso::HtmlConvert : IsoDoc::Iso::WordConvert
      out = render(converter(klass), t)
      expect(out).to include("Fast track procedure")
      file.include?("prf") or expect(out).to match(/ISO 17301-1(?!:)/)
      file.start_with?("html") and
        expect(out).to include("<b>ICS:</b> 67.060, 01.040")
      out = render(converter(klass, ics: false, fast_track: "false"), t)
      expect(out).not_to include("Fast track procedure")
      expect(out).not_to include("<b>ICS:</b>")
    end
  end

  %w(en fr ru).each do |lang|
    it "renders the copyright year from bibdata in the #{lang} boilerplate" do
      hdr = ASCIIDOC_BLANK_HDR
        .sub(":nodoc:", ":nodoc:\n:copyright-year: 2001\n:language: #{lang}")
      xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
        #{hdr}
        text
      INPUT
      dates = xml
        .xpath("//xmlns:copyright-statement//xmlns:span[@class = 'date']")
        .map(&:text)
      expect(dates).not_to be_empty
      expect(dates.uniq).to eq ["2001"]
    end
  end

  %w(boilerplate.adoc boilerplate-fr.adoc boilerplate-ru.adoc).each do |file|
    it "uses bibdata.copyright in #{file}" do
      text = File.read(lib_dir("metanorma", "iso", file), encoding: "UTF-8")
      expect(text).not_to include("{{ docyear }}")
      expect(text).to include(docyear)
    end
  end
end
