require "spec_helper"

RSpec.describe Asciidoctor::ISO do

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
    system "echo 'XXX' > ~/.relaton-bib.json"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{FLUSH_CACHE_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.json")).to be true
    json = File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8")
    expect(json).to be_equivalent_to <<~"OUTPUT"
    {"ISO 123:2001":{"fetched":"#{Date.today}","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO123\\">\\n  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Rubber latex -- Sampling</title>\\n  <title format=\\"text/plain\\" language=\\"fr\\" script=\\"Latn\\">Latex de caoutchouc -- ?chantillonnage</title>\\n  <source type=\\"src\\">https://www.iso.org/standard/23281.html</source>\\n  <source type=\\"obp\\">https://www.iso.org/obp/ui/#!iso:std:23281:en</source>\\n  <source type=\\"rss\\">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</source>\\n  <docidentifier>ISO 123</docidentifier>\\n  <date type=\\"published\\">\\n    <on>2001</on>\\n  </date>\\n  <contributor>\\n    <role type=\\"publisher\\"/>\\n    <organization>\\n      <name>International Organization for Standardization</name>\\n      <abbreviation>ISO</abbreviation>\\n      <uri>www.iso.org</uri>\\n    </organization>\\n  </contributor>\\n  <edition>3</edition>\\n  <language>en</language>\\n  <language>fr</language>\\n  <script>Latn</script>\\n  <status>Published</status>\\n  <copyright>\\n    <from>2001</from>\\n    <owner>\\n      <organization>\\n        <name>ISO</name>\\n        <abbreviation></abbreviation>\\n      </organization>\\n    </owner>\\n  </copyright>\\n  <relation type=\\"obsoletes\\">\\n    <bibitem>\\n      <formattedref>ISO 123:1985</formattedref>\\n      <docidentifier>ISO 123:1985</docidentifier>\\n    </bibitem>\\n  </relation>\\n  <relation type=\\"updates\\">\\n    <bibitem>\\n      <formattedref>ISO 123:2001</formattedref>\\n      <docidentifier>ISO 123:2001</docidentifier>\\n    </bibitem>\\n  </relation>\\n</bibitem>"}}
    OUTPUT

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

    json = File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8")
    expect(json).to match(%r{"ISO 123:2001"})

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

    json = File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8")
    expect(json).to match(%r{"ISO 123:2001"})
    json = File.read("test.relaton.json", encoding: "utf-8")
    expect(json).to match(%r{"ISO 123:2001"})

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end

  it "fetches uncached references" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"
    command = %(echo '{"ISO 123:2001":{"fetched":"#{Date.today}","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO123\\">  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Rubber latex -- Sampling</title><docidentifier>ISO 123</docidentifier></bibitem>"}}' > ~/.relaton-bib.json)
    system command
    mock_isobib_get_124

    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
      * [[[iso124,ISO 124:2014]]] _Standard_
    INPUT

    json = File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8")
    expect(json).to be_equivalent_to <<~"OUTPUT"
{"ISO 123:2001":{"fetched":"#{Date.today}","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO123\\">  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Rubber latex -- Sampling</title><docidentifier>ISO 123</docidentifier></bibitem>"},"ISO 124:2014":{"fetched":"#{Date.today}","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO124\\">\\n  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Latex, rubber -- Determination of total solids content</title>\\n  <title format=\\"text/plain\\" language=\\"fr\\" script=\\"Latn\\">Latex de caoutchouc -- Détermination des matières solides totales</title>\\n  <source type=\\"src\\">https://www.iso.org/standard/61884.html</source>\\n  <source type=\\"obp\\">https://www.iso.org/obp/ui/#!iso:std:61884:en</source>\\n  <source type=\\"rss\\">https://www.iso.org/contents/data/standard/06/18/61884.detail.rss</source>\\n  <docidentifier>ISO 124</docidentifier>\\n  <date type=\\"published\\">\\n    <on>2014</on>\\n  </date>\\n  <contributor>\\n    <role type=\\"publisher\\"/>\\n    <organization>\\n      <name>International Organization for Standardization</name>\\n      <abbreviation>ISO</abbreviation>\\n      <uri>www.iso.org</uri>\\n    </organization>\\n  </contributor>\\n  <edition>7</edition>\\n  <language>en</language>\\n  <language>fr</language>\\n  <script>Latn</script>\\n  <abstract format=\\"plain\\" language=\\"en\\" script=\\"Latn\\">ISO 124:2014 specifies methods for the determination of the total solids content of natural rubber field and concentrated latices and synthetic rubber latex. These methods are not necessarily suitable for latex from natural sources other than the Hevea brasiliensis, for vulcanized latex, for compounded latex, or for artificial dispersions of rubber.</abstract>\\n  <abstract format=\\"plain\\" language=\\"fr\\" script=\\"Latn\\">L'ISO 124:2014 spécifie des méthodes pour la détermination des matières solides totales dans le latex de plantation, le latex de concentré de caoutchouc naturel et le latex de caoutchouc synthétique. Ces méthodes ne conviennent pas nécessairement au latex d'origine naturelle autre que celui de l'Hevea brasiliensis, au latex vulcanisé, aux mélanges de latex, ou aux dispersions artificielles de caoutchouc.</abstract>\\n  <status>Published</status>\\n  <copyright>\\n    <from>2014</from>\\n    <owner>\\n      <organization>\\n        <name>ISO</name>\\n        <abbreviation></abbreviation>\\n      </organization>\\n    </owner>\\n  </copyright>\\n  <relation type=\\"obsoletes\\">\\n    <bibitem>\\n      <formattedref>ISO 124:2011</formattedref>\\n      <docidentifier>ISO 124:2011</docidentifier>\\n    </bibitem>\\n  </relation>\\n</bibitem>"}}
	OUTPUT

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
  end

    it "prioritises local over global cache values" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"
    system "rm test.relaton.json"
    system %(echo '{"ISO 123:2001":{"fetched":"#{Date.today}","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO123\\">  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Rubber latex -- Sampling</title><docidentifier>ISO 123</docidentifier></bibitem>"}, "ISO 124":{"fetched":"#{Date.today}","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO124\\">  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Latex, rubber -- Determination of total solids content</title><docidentifier>ISO 124</docidentifier></bibitem>"}}' > ~/.relaton-bib.json)
    system %(echo '{"ISO 124":{"fetched":"#{Date.today}","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO124\\">  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Latex, rubber -- Replacement</title><docidentifier>ISO 124</docidentifier></bibitem>"}}' > test.relaton.json)
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{LOCAL_CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
      * [[[iso124,ISO 124]]] _Standard_
    INPUT
     #{BLANK_HDR}
       <sections>

       </sections><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
       <bibitem type="international-standard" id="iso123">  <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title><docidentifier>ISO 123</docidentifier></bibitem>
       <bibitem type="international-standard" id="iso124">  <title format="text/plain" language="en" script="Latn">Latex, rubber -- Replacement</title><docidentifier>ISO 124</docidentifier></bibitem>
       </references></bibliography>
       </iso-standard>
    OUTPUT

    json = File.read("#{Dir.home}/.relaton-bib.json", encoding: "utf-8")
    expect(json).to be_equivalent_to <<~"OUTPUT"
    {"ISO 123:2001":{"fetched":"2018-06-29","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO123\\">  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Rubber latex -- Sampling</title><docidentifier>ISO 123</docidentifier></bibitem>"},"ISO 124":{"fetched":"2018-06-29","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO124\\">  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Latex, rubber -- Determination of total solids content</title><docidentifier>ISO 124</docidentifier></bibitem>"}}
OUTPUT
    json = File.read("test.relaton.json", encoding: "utf-8")
    expect(json).to be_equivalent_to <<~"OUTPUT"
    {"ISO 124":{"fetched":"2018-06-29","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO124\\">  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Latex, rubber -- Replacement</title><docidentifier>ISO 124</docidentifier></bibitem>"},"ISO 123:2001":{"fetched":"2018-06-29","bib":"<bibitem type=\\"international-standard\\" id=\\"ISO123\\">  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Rubber latex -- Sampling</title><docidentifier>ISO 123</docidentifier></bibitem>"}}
OUTPUT

    system "rm ~/.relaton-bib.json"
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
end

    private

    def mock_isobib_get_123
      expect(Isobib::IsoBibliography).to receive(:isobib_get).with("ISO 123", "2001", {}) do
        <<~"OUTPUT"
        <bibitem type=\"international-standard\" id=\"ISO123\">\n  <title format=\"text/plain\" language=\"en\" script=\"Latn\">Rubber latex -- Sampling</title>\n  <title format=\"text/plain\" language=\"fr\" script=\"Latn\">Latex de caoutchouc -- ?chantillonnage</title>\n  <source type=\"src\">https://www.iso.org/standard/23281.html</source>\n  <source type=\"obp\">https://www.iso.org/obp/ui/#!iso:std:23281:en</source>\n  <source type=\"rss\">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</source>\n  <docidentifier>ISO 123</docidentifier>\n  <date type=\"published\">\n    <on>2001</on>\n  </date>\n  <contributor>\n    <role type=\"publisher\"/>\n    <organization>\n      <name>International Organization for Standardization</name>\n      <abbreviation>ISO</abbreviation>\n      <uri>www.iso.org</uri>\n    </organization>\n  </contributor>\n  <edition>3</edition>\n  <language>en</language>\n  <language>fr</language>\n  <script>Latn</script>\n  <status>Published</status>\n  <copyright>\n    <from>2001</from>\n    <owner>\n      <organization>\n        <name>ISO</name>\n        <abbreviation></abbreviation>\n      </organization>\n    </owner>\n  </copyright>\n  <relation type=\"obsoletes\">\n    <bibitem>\n      <formattedref>ISO 123:1985</formattedref>\n      <docidentifier>ISO 123:1985</docidentifier>\n    </bibitem>\n  </relation>\n  <relation type=\"updates\">\n    <bibitem>\n      <formattedref>ISO 123:2001</formattedref>\n      <docidentifier>ISO 123:2001</docidentifier>\n    </bibitem>\n  </relation>\n</bibitem>
        OUTPUT
      end
    end
        def mock_isobib_get_124
      expect(Isobib::IsoBibliography).to receive(:isobib_get).with("ISO 124", "2014", {}) do
        <<~"OUTPUT"
        <bibitem type=\\"international-standard\\" id=\\"ISO124\\">\\n  <title format=\\"text/plain\\" language=\\"en\\" script=\\"Latn\\">Latex, rubber -- Determination of total solids content</title>\\n  <title format=\\"text/plain\\" language=\\"fr\\" script=\\"Latn\\">Latex de caoutchouc -- Détermination des matt
ières solides totales</title>\\n  <source type=\\"src\\">https://www.iso.org/standard/61884.html</source>\\n  <source type=\\"obp\\">https://www.iso.org/oo
bp/ui/#!iso:std:61884:en</source>\\n  <source type=\\"rss\\">https://www.iso.org/contents/data/standard/06/18/61884.detail.rss</source>\\n  <docidentifier>ISO 124</docidentifier>\\n  <date type=\\"published\\">\\n    <on>2014</on>\\n  </date>\\n  <contributor>\\n    <role type=\\"publisher\\"/>\\n    <organization>\\n      <name>International Organization for Standardization</name>\\n      <abbreviation>ISO</abbreviation>\\n      <uri>www.iso.org</uri>\\n    </organization>\\n  </contributor>\\n  <edition>7</edition>\\n  <language>en</language>\\n  <language>fr</language>\\n  <script>Latn</script>\\n  <abstract format=\\"plain\\" language=\\"en\\" script=\\"Latn\\">ISO 124:2014 specifies methods for the determination of the total solids content of natural rubber field and concentrated latices and synthetic rubber latex. These methods are not necessarily suitable for latex from natural sources other than the Hevea brasiliensis, for vulcanized latex, for compounded latex, or for artificial dispersions of rubber.</abstract>\\n  <abstract format=\\"plain\\" language=\\"fr\\" script=\\"Latn\\">L'ISO 124:2014 spécifie des méthodes pour la détermination des matières solides totales dans le latex de plantation, le latex de cc
oncentré de caoutchouc naturel et le latex de caoutchouc synthétique. Ces méthodes ne conviennent pas nécessairement au latex d'origine naturelle autree
 que celui de l'Hevea brasiliensis, au latex vulcanisé, aux mélanges de latex, ou aux dispersions artificielles de caoutchouc.</abstract>\\n  <status>Pubb
lished</status>\\n  <copyright>\\n    <from>2014</from>\\n    <owner>\\n      <organization>\\n        <name>ISO</name>\\n        <abbreviation></abbreviation>\\n      </organization>\\n    </owner>\\n  </copyright>\\n  <relation type=\\"obsoletes\\">\\n    <bibitem>\\n      <formattedref>ISO 124:2011</formattedref>\\n      <docidentifier>ISO 124:2011</docidentifier>\\n    </bibitem>\\n  </relation>\\n</bibitem>
        OUTPUT
      end
    end

end
