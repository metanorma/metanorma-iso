require "spec_helper"

RSpec.describe Asciidoctor::ISO do

  ISO_123_SHORT = <<~EOS
<bibitem type="international-standard" id="ISO123">
  <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>
  <docidentifier>ISO 123</docidentifier>
</bibitem>
EOS

  ISO_124_SHORT = <<~EOS
<bibitem type="international-standard" id="ISO124">
  <title format="text/plain" language="en" script="Latn">Latex, rubber -- Determination of total solids content</title>
  <docidentifier>ISO 124</docidentifier>
</bibitem>
EOS

  ISO_124_SHORT_ALT = <<~EOS
<bibitem type="international-standard" id="ISO124">
  <title format="text/plain" language="en" script="Latn">Latex, rubber -- Replacement</title>
  <docidentifier>ISO 124</docidentifier>
</bibitem>
EOS

  ISOBIB_123_DATED = <<~EOS
<bibitem type="international-standard" id="ISO123">  <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>  <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- ?chantillonnage</title>  <source type="src">https://www.iso.org/standard/23281.html</source>  <source type="obp">https://www.iso.org/obp/ui/#!iso:std:23281:en</source>  <source type="rss">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</source>  <docidentifier>ISO 123</docidentifier>  <date type="published">    <on>2001</on>  </date>  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>  <edition>3</edition>  <language>en</language>  <language>fr</language>  <script>Latn</script>  <status>Published</status>  <copyright>    <from>2001</from>    <owner>      <organization>        <name>ISO</name>        <abbreviation></abbreviation>      </organization>    </owner>  </copyright>  <relation type="obsoletes">    <bibitem>      <formattedref>ISO 123:1985</formattedref>      <docidentifier>ISO 123:1985</docidentifier>    </bibitem>  </relation>  <relation type="updates">    <bibitem>      <formattedref>ISO 123:2001</formattedref>      <docidentifier>ISO 123:2001</docidentifier>    </bibitem>  </relation></bibitem>
EOS

  ISOBIB_123_UNDATED = <<~EOS
<bibitem type="international-standard" id="ISO123">  <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>  <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- ?chantillonnage</title>  <source type="src">https://www.iso.org/standard/23281.html</source>  <source type="obp">https://www.iso.org/obp/ui/#!iso:std:23281:en</source>  <source type="rss">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</source>  <docidentifier>ISO 123</docidentifier>  <date type="published">    <on>2001</on>  </date>  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>  <edition>3</edition>  <language>en</language>  <language>fr</language>  <script>Latn</script>  <status>Published</status>  <copyright>    <from>2001</from>    <owner>      <organization>        <name>ISO</name>        <abbreviation></abbreviation>      </organization>    </owner>  </copyright>  <relation type="obsoletes">    <bibitem>      <formattedref>ISO 123:1985</formattedref>      <docidentifier>ISO 123:1985</docidentifier>    </bibitem>  </relation>  <relation type="updates">    <bibitem>      <formattedref>ISO 123:2001</formattedref>      <docidentifier>ISO 123:2001</docidentifier>    </bibitem>  </relation></bibitem>
EOS


  ISOBIB_124_DATED = <<~EOS
<bibitem type="international-standard" id="ISO124">  <title format="text/plain" language="en" script="Latn">Latex, rubber -- Determination of total solids content</title>  <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- Détermination des matières solides totales</title>  <source type="src">https://www.iso.org/standard/61884.html</source>  <source type="obp">https://www.iso.org/obp/ui/#!iso:std:61884:en</source>  <source type="rss">https://www.iso.org/contents/data/standard/06/18/61884.detail.rss</source>  <docidentifier>ISO 124</docidentifier>  <date type="published">    <on>2014</on>  </date>  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>  <edition>7</edition>  <language>en</language>  <language>fr</language>  <script>Latn</script>  <abstract format="plain" language="en" script="Latn">ISO 124:2014 specifies methods for the determination of the total solids content of natural rubber field and concentrated latices and synthetic rubber latex. These methods are not necessarily suitable for latex from natural sources other than the Hevea brasiliensis, for vulcanized latex, for compounded latex, or for artificial dispersions of rubber.</abstract>  <abstract format="plain" language="fr" script="Latn">L'ISO 124:2014 spécifie des méthodes pour la détermination des matières solides totales dans le latex de plantation, le latex de concentré de caoutchouc naturel et le latex de caoutchouc synthétique. Ces méthodes ne conviennent pas nécessairement au latex d'origine naturelle autre que celui de l'Hevea brasiliensis, au latex vulcanisé, aux mélanges de latex, ou aux dispersions artificielles de caoutchouc.</abstract>  <status>Published</status>  <copyright>    <from>2014</from>    <owner>      <organization>        <name>ISO</name>        <abbreviation></abbreviation>      </organization>    </owner>  </copyright>  <relation type="obsoletes">    <bibitem>      <formattedref>ISO 124:2011</formattedref>      <docidentifier>ISO 124:2011</docidentifier>    </bibitem>  </relation></bibitem>
EOS


  it "does not activate biblio caches if isobib disabled" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"
    system "rm -f test.relaton.json"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.json")).to be false
    expect(File.exist?("test.relaton.json")).to be false

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end


  it "does not activate biblio caches if isobib caching disabled" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"
    system "rm -f test.relaton.json"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.json")).to be false
    expect(File.exist?("test.relaton.json")).to be false

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end

  it "flushes biblio caches" do
    system "cp ~/.relaton-bib.json ~/.relaton-bib.json1"

    File.open("#{Dir.home}/.relaton-bib.json", "w") do |f|
      f.write "XXX"
    end

    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{FLUSH_CACHE_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.json")).to be true

    json = JSON.parse(File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8"))
    expect(json["ISO 123:2001"]["fetched"]).to eq(Date.today.to_s)
    expect(json["ISO 123:2001"]["bib"]).to be_equivalent_to(ISOBIB_123_DATED)

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end


  it "activates global cache" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"
    system "rm -f test.relaton.json"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.json")).to be true
    expect(File.exist?("test.relaton.json")).to be false

    json = JSON.parse(File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8"))
    expect(json).to have_key("ISO 123:2001")

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end

  it "activates local cache" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"
    system "rm -f test.relaton.json"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{LOCAL_CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.json")).to be true
    expect(File.exist?("test.relaton.json")).to be true

    json = JSON.parse(File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8"))
    expect(json).to have_key("ISO 123:2001")

    json = JSON.parse(File.read("test.relaton.json", encoding: "utf-8"))
    expect(json).to have_key("ISO 123:2001")

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end


  it "fetches uncached references" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"

    File.open("#{Dir.home}/.relaton-bib.json", "w") do |f|
      f.write({
        "ISO 123:2001": {
          "fetched": Date.today.to_s,
          "bib": ISO_123_SHORT
        }
      }.to_json)
    end

    mock_isobib_get_124

    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
      * [[[iso124,ISO 124:2014]]] _Standard_
    INPUT

    json = JSON.parse(File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8"))
    expect(json["ISO 123:2001"]["fetched"]).to eq(Date.today.to_s)
    expect(json["ISO 124:2014"]["fetched"]).to eq(Date.today.to_s)
    expect(json["ISO 123:2001"]["bib"]).to be_equivalent_to(ISO_123_SHORT)
    expect(json["ISO 124:2014"]["bib"]).to be_equivalent_to(ISOBIB_124_DATED)

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end

  it "expires stale undated references" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"

    File.open("#{Dir.home}/.relaton-bib.json", "w") do |f|
      f.write({
        "ISO 123": {
          "fetched": (Date.today - 90).to_s,
          "bib": ISO_123_SHORT
        }
      }.to_json)
    end

    mock_isobib_get_123_undated

    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123]]] _Standard_
    INPUT

    json = JSON.parse(File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8"))
    expect(json["ISO 123"]["fetched"]).to eq(Date.today.to_s)
    expect(json["ISO 123"]["bib"]).to be_equivalent_to(ISOBIB_123_UNDATED)

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end

  it "does not expire stale dated references" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"

    File.open("#{Dir.home}/.relaton-bib.json", "w") do |f|
      f.write({
        "ISO 123:2001": {
          "fetched": (Date.today - 90).to_s,
          "bib": ISO_123_SHORT
        }
      }.to_json)
    end

    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT

    json = JSON.parse(File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8"))
    expect(json["ISO 123:2001"]["fetched"]).to eq((Date.today - 90).to_s)
    expect(json["ISO 123:2001"]["bib"]).to be_equivalent_to(ISO_123_SHORT)

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end

  it "prioritises local over global cache values" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"
    system "rm test.relaton.json"

    File.open("#{Dir.home}/.relaton-bib.json", "w") do |f|
      f.write({
        "ISO 123:2001": {
          "fetched": Date.today.to_s,
          "bib": ISO_123_SHORT
        },
        "ISO 124": {
          "fetched": Date.today.to_s,
          "bib": ISO_124_SHORT
        }
      }.to_json)
    end

    File.open("test.relaton.json", "w") do |f|
      f.write({
        "ISO 124": {
          "fetched": Date.today.to_s,
          "bib": ISO_124_SHORT_ALT
        }
      }.to_json)
    end

    input = <<~EOS
#{LOCAL_CACHED_ISOBIB_BLANK_HDR}
  [bibliography]
  == Normative References

  * [[[iso123,ISO 123:2001]]] _Standard_
  * [[[iso124,ISO 124]]] _Standard_
EOS

    output = <<~EOS
#{BLANK_HDR}
<sections>
</sections>
<bibliography>
<references id="_" obligation="informative">
 <title>Normative References</title>
 #{ISO_123_SHORT}
 #{ISO_124_SHORT_ALT}
</references></bibliography>
</iso-standard>
EOS

    expect(strip_guid(Asciidoctor.convert(input, backend: :iso, header_footer: true))).to be_equivalent_to(output)

    json = JSON.parse(File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8"))

    expect(json["ISO 123:2001"]["fetched"]).to eq(Date.today.to_s)
    expect(json["ISO 124"]["fetched"]).to eq(Date.today.to_s)
    expect(json["ISO 123:2001"]["bib"]).to be_equivalent_to(ISO_123_SHORT)
    expect(json["ISO 124"]["bib"]).to be_equivalent_to(ISO_124_SHORT)

    json_local = JSON.parse(File.read("test.relaton.json", encoding: "utf-8"))

    expect(json_local["ISO 123:2001"]["fetched"]).to eq(Date.today.to_s)
    expect(json_local["ISO 124"]["fetched"]).to eq(Date.today.to_s)
    expect(json_local["ISO 123:2001"]["bib"]).to be_equivalent_to(ISO_123_SHORT)
    expect(json_local["ISO 124"]["bib"]).to be_equivalent_to(ISO_124_SHORT_ALT)

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end

private

  def mock_isobib_get_123
    expect(Isobib::IsoBibliography).to receive(:get).with("ISO 123", "2001", {}).and_return(ISOBIB_123_DATED)
  end

  def mock_isobib_get_123_undated
    expect(Isobib::IsoBibliography).to receive(:get).with("ISO 123", nil, {}).and_return(ISOBIB_123_UNDATED)
  end

  def mock_isobib_get_124
    expect(Isobib::IsoBibliography).to receive(:get).with("ISO 124", "2014", {}).and_return(ISOBIB_124_DATED)
  end

end
