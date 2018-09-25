require "spec_helper"
require "isobib"
require "fileutils"

RSpec.describe Asciidoctor::ISO do

  ISO_123_SHORT = <<~EOS
<bibitem type="international-standard" id="ISO123">
  <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>
  <docidentifier>ISO 123</docidentifier>
  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>
  <status>Published</status>
</bibitem>
EOS

  ISO_124_SHORT = <<~EOS
<bibitem type="international-standard" id="ISO124">
  <title format="text/plain" language="en" script="Latn">Latex, rubber -- Determination of total solids content</title>
  <docidentifier>ISO 124</docidentifier>
  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>
  <status>Published</status>
</bibitem>
EOS

  ISO_124_SHORT_ALT = <<~EOS
<bibitem type="international-standard" id="ISO124">
  <title format="text/plain" language="en" script="Latn">Latex, rubber -- Replacement</title>
  <docidentifier>ISO 124</docidentifier>
  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>
  <status>Published</status>
</bibitem>
EOS

  ISOBIB_123_DATED = <<~EOS
<bibitem type="international-standard" id="ISO123">  <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>  <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- ?chantillonnage</title>  <uri type="src">https://www.iso.org/standard/23281.html</uri>  <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:23281:en</uri>  <uri type="rss">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</uri>  <docidentifier>ISO 123</docidentifier>  <date type="published">    <on>2001</on>  </date>  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>  <edition>3</edition>  <language>en</language>  <language>fr</language>  <script>Latn</script>  <status>Published</status>  <copyright>    <from>2001</from>    <owner>      <organization>        <name>ISO</name>        </organization>    </owner>  </copyright>  <relation type="obsoletes">    <bibitem>      <formattedref>ISO 123:1985</formattedref>      </bibitem>  </relation>  <relation type="updates">    <bibitem>      <formattedref>ISO 123:2001</formattedref>      </bibitem>  </relation></bibitem>
EOS

  ISOBIB_123_UNDATED = <<~EOS
<bibitem type="international-standard" id="ISO123">  <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>  <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- ?chantillonnage</title>  <uri type="src">https://www.iso.org/standard/23281.html</uri>  <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:23281:en</uri>  <uri type="rss">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</uri>  <docidentifier>ISO 123</docidentifier>  <date type="published">    <on>2001</on>  </date>  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>  <edition>3</edition>  <language>en</language>  <language>fr</language>  <script>Latn</script>  <status>Published</status>  <copyright>    <from>2001</from>    <owner>      <organization>        <name>ISO</name>        </organization>    </owner>  </copyright>  <relation type="obsoletes">    <bibitem>      <formattedref>ISO 123:1985</formattedref>      </bibitem>  </relation>  <relation type="updates">    <bibitem>      <formattedref>ISO 123:2001</formattedref>      </bibitem>  </relation></bibitem>
EOS


  ISOBIB_124_DATED = <<~EOS
<bibitem type="international-standard" id="ISO124">  <title format="text/plain" language="en" script="Latn">Latex, rubber -- Determination of total solids content</title>  <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- Détermination des matières solides totales</title>  <uri type="src">https://www.iso.org/standard/61884.html</uri>  <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:61884:en</uri>  <uri type="rss">https://www.iso.org/contents/data/standard/06/18/61884.detail.rss</uri>  <docidentifier>ISO 124</docidentifier>  <date type="published">    <on>2014</on>  </date>  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>  <edition>7</edition>  <language>en</language>  <language>fr</language>  <script>Latn</script>  <abstract format="plain" language="en" script="Latn">ISO 124:2014 specifies methods for the determination of the total solids content of natural rubber field and concentrated latices and synthetic rubber latex. These methods are not necessarily suitable for latex from natural sources other than the Hevea brasiliensis, for vulcanized latex, for compounded latex, or for artificial dispersions of rubber.</abstract>  <abstract format="plain" language="fr" script="Latn">L'ISO 124:2014 spécifie des méthodes pour la détermination des matières solides totales dans le latex de plantation, le latex de concentré de caoutchouc naturel et le latex de caoutchouc synthétique. Ces méthodes ne conviennent pas nécessairement au latex d'origine naturelle autre que celui de l'Hevea brasiliensis, au latex vulcanisé, aux mélanges de latex, ou aux dispersions artificielles de caoutchouc.</abstract>  <status>Published</status>  <copyright>    <from>2014</from>    <owner>      <organization>        <name>ISO</name>        </organization>    </owner>  </copyright>  <relation type="obsoletes">    <bibitem>      <formattedref>ISO 124:2011</formattedref>      </bibitem>  </relation></bibitem>
EOS

  it "does not activate biblio caches if isobib disabled" do
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore"), File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.mv File.expand_path("~/.iev.pstore"), File.expand_path("~/.iev.pstore1"), force: true
    FileUtils.rm_f "test.relaton.pstore"
    FileUtils.rm_f "test.iev.pstore"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.pstore")).to be false
    expect(File.exist?("#{Dir.home}/.iev.pstore")).to be false
    expect(File.exist?("test.relaton.pstore")).to be false
    expect(File.exist?("test.iev.pstore")).to be false

    FileUtils.rm_f File.expand_path("~/.relaton-bib.pstore")
    FileUtils.rm_f File.expand_path("~/.iev.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton-bib.pstore"), force: true
    FileUtils.mv File.expand_path("~/.iev.pstore1"), File.expand_path("~/.iev.pstore"), force: true
  end

  it "does not activate biblio caches if isobib caching disabled" do
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore"), File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.mv File.expand_path("~/.iev.pstore"), File.expand_path("~/.iev.pstore1"), force: true
    FileUtils.rm_f "test.relaton.pstore"
    FileUtils.rm_f "test.iev.pstore"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.pstore")).to be false
    expect(File.exist?("#{Dir.home}/.iev.pstore")).to be false
    expect(File.exist?("test.relaton.pstore")).to be false
    expect(File.exist?("test.iev.pstore")).to be false

    FileUtils.rm_f File.expand_path("~/.relaton-bib.pstore")
    FileUtils.rm_f File.expand_path("~/.iev.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton-bib.pstore"), force: true
    FileUtils.mv File.expand_path("~/.iev.pstore1"), File.expand_path("~/.iev.pstore"), force: true
  end

  it "flushes biblio caches" do
    FileUtils.cp File.expand_path("~/.relaton-bib.pstore"), File.expand_path("~/.relaton-bib.pstore1")
    FileUtils.cp File.expand_path("~/.iev.pstore"), File.expand_path("~/.iev.pstore1")

    File.open("#{Dir.home}/.relaton-bib.pstore", "w") { |f| f.write "XXX" }
    FileUtils.rm_f File.expand_path("~/.iev.pstore")

    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{FLUSH_CACHE_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.pstore")).to be true
    expect(File.exist?("#{Dir.home}/.iev.pstore")).to be true

    db = Relaton::Db.new "#{Dir.home}/.relaton-bib.pstore", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry["fetched"].to_s).to eq(Date.today.to_s)
    expect(entry["bib"].to_xml).to be_equivalent_to(ISOBIB_123_DATED)

    FileUtils.rm_f File.expand_path("~/.relaton-bib.pstore")
    FileUtils.rm_f File.expand_path("~/.iev.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton-bib.pstore"), force: true
    FileUtils.mv File.expand_path("~/.iev.pstore1"), File.expand_path("~/.iev.pstore"), force: true
  end

  it "activates global cache" do
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore"), File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_f "test.relaton.pstore"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.pstore")).to be true
    expect(File.exist?("test.relaton.pstore")).to be false

    db = Relaton::Db.new "#{Dir.home}/.relaton-bib.pstore", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry).to_not be nil

    FileUtils.rm_f File.expand_path("~/.relaton-bib.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton-bib.pstore"), force: true
  end

  it "activates local cache" do
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore"), File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_f "test.relaton.pstore"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{LOCAL_CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton-bib.pstore")).to be true
    expect(File.exist?("test.relaton.pstore")).to be true

    db = Relaton::Db.new "#{Dir.home}/.relaton-bib.pstore", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry).to_not be nil

    db = Relaton::Db.new "test.relaton.pstore", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry).to_not be nil

    FileUtils.rm_f File.expand_path("~/.relaton-bib.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton-bib.pstore"), force: true
  end

  it "fetches uncached references" do
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore"), File.expand_path("~/.relaton-bib.pstore1"), force: true
    db = Relaton::Db.new "#{Dir.home}/.relaton-bib.pstore", nil
    db.save_entry("ISO(ISO 123:2001)",
        {
          "fetched" => Date.today.to_s,
          "bib" => IsoBibItem.from_xml(ISO_123_SHORT)
        }
      )

    mock_isobib_get_124

    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
      * [[[iso124,ISO 124:2014]]] _Standard_
    INPUT

    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry["fetched"].to_s).to eq(Date.today.to_s)
    expect(entry["bib"].to_xml).to be_equivalent_to(ISO_123_SHORT)
    entry = db.load_entry("ISO(ISO 124:2014)")
    expect(entry["fetched"].to_s).to eq(Date.today.to_s)
    expect(entry["bib"].to_xml).to be_equivalent_to(ISOBIB_124_DATED)

    FileUtils.rm_f File.expand_path("~/.relaton-bib.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton-bib.pstore"), force: true
  end

  it "expires stale undated references" do
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore"), File.expand_path("~/.relaton-bib.pstore1"), force: true

        db = Relaton::Db.new "#{Dir.home}/.relaton-bib.pstore", nil
        db.save_entry("ISO 123",
        {
          "fetched" => (Date.today - 90),
          "bib" => IsoBibItem.from_xml(ISO_123_SHORT)
        }
      )

    mock_isobib_get_123_undated

    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123]]] _Standard_
    INPUT

        entry = db.load_entry("ISO(ISO 123)")
            expect(entry["fetched"].to_s).to eq(Date.today.to_s)
    expect(entry["bib"].to_xml).to be_equivalent_to(ISOBIB_123_UNDATED)

    FileUtils.rm_f File.expand_path("~/.relaton-bib.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton-bib.pstore"), force: true
  end

  it "does not expire stale dated references" do
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore"), File.expand_path("~/.relaton-bib.pstore1"), force: true

            db = Relaton::Db.new "#{Dir.home}/.relaton-bib.pstore", nil
            db.save_entry("ISO(ISO 123:2001)",
        {
          "fetched" => (Date.today - 90),
          "bib" => IsoBibItem.from_xml(ISO_123_SHORT)
        }
      )

    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT

            entry = db.load_entry("ISO(ISO 123:2001)")
            expect(entry["fetched"].to_s).to eq((Date.today - 90).to_s)
    expect(entry["bib"].to_xml).to be_equivalent_to(ISO_123_SHORT)

    FileUtils.rm_f File.expand_path("~/.relaton-bib.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton-bib.pstore"), force: true
  end

  it "prioritises local over global cache values" do
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore"), File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_f "test.relaton.pstore"

    db = Relaton::Db.new "#{Dir.home}/.relaton-bib.pstore", nil
    db.save_entry("ISO(ISO 123:2001)",
        {
          "fetched" => Date.today,
          "bib" => IsoBibItem.from_xml(ISO_123_SHORT)
        }
      )
    db.save_entry("ISO(ISO 124)",
        {
          "fetched" => Date.today,
          "bib" => IsoBibItem.from_xml(ISO_124_SHORT)
        }
      )

    localdb = Relaton::Db.new "test.relaton.pstore", nil
    localdb.save_entry("ISO(ISO 124)",
        {
          "fetched" => Date.today,
          "bib" => IsoBibItem.from_xml(ISO_124_SHORT_ALT)
        }
      )

    input = <<~EOS
#{LOCAL_CACHED_ISOBIB_BLANK_HDR}
[bibliography]
== Normative References

* [[[ISO123,ISO 123:2001]]] _Standard_
* [[[ISO124,ISO 124]]] _Standard_
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

    expect(db.load_entry("ISO(ISO 123:2001)")["bib"].to_xml).to be_equivalent_to(ISO_123_SHORT)
    expect(db.load_entry("ISO(ISO 124)")["bib"].to_xml).to be_equivalent_to(ISO_124_SHORT)
    expect(localdb.load_entry("ISO(ISO 123:2001)")["bib"].to_xml).to be_equivalent_to(ISO_123_SHORT)
    expect(localdb.load_entry("ISO(ISO 124)")["bib"].to_xml).to be_equivalent_to(ISO_124_SHORT_ALT)

    FileUtils.rm_f File.expand_path("~/.relaton-bib.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton-bib.pstore"), force: true
  end

private

  def mock_isobib_get_123
    expect(Isobib::IsoBibliography).to receive(:get).with("ISO 123", "2001", {}).and_return(IsoBibItem.from_xml(ISOBIB_123_DATED))
  end

  def mock_isobib_get_123_undated
    expect(Isobib::IsoBibliography).to receive(:get).with("ISO 123", nil, {}).and_return(IsoBibItem.from_xml(ISOBIB_123_UNDATED))
  end

  def mock_isobib_get_124
    expect(Isobib::IsoBibliography).to receive(:get).with("ISO 124", "2014", {}).and_return(IsoBibItem.from_xml(ISOBIB_124_DATED))
  end

end
