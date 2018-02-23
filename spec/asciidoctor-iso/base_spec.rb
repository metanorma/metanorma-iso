require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "has a version number" do
    expect(Asciidoctor::ISO::VERSION).not_to be nil
  end

  it "processes a blank document" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
    INPUT
    <?xml version="1.0" encoding="UTF-8"?>
<iso-standard xmlns="http://riboseinc.com/isoxml">
<bibdata type="article">
  <title>
    <title-main language="en" format="text/plain"/>
  </title>
  <title>
    <title-main language="fr" format="text/plain"/>
  </title>
  <docidentifier>
    <project-number/>
  </docidentifier>
  <contributor>
    <role type="author"/>
    <organization>
      <name>ISO</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>ISO</name>
    </organization>
  </contributor>
  <language/>
  <script>Latn</script>
  <status>
    <stage>60</stage>
    <substage>60</substage>
  </status>
  <copyright>
    <from>2018</from>
    <owner>
      <organization>
        <name>ISO</name>
      </organization>
    </owner>
  </copyright>
  <editorialgroup>
    <technical-committee/>
    <subcommittee/>
    <workgroup/>
  </editorialgroup>
</bibdata><version/>
<sections/>
</iso-standard>
    OUTPUT

  end
end
