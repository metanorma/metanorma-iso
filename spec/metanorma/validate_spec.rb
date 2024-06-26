require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::ISO do
  context "when xref_error.adoc compilation" do
    it "generates error file" do
      FileUtils.rm_f "xref_error.err.html"
      File.write("xref_error.adoc", <<~CONTENT)
        = X
        A

        == Clause

        <<a,b>>
      CONTENT

      expect do
        mock_pdf
        Metanorma::Compile
          .new
          .compile("xref_error.adoc", type: "iso", install_fonts: false)
      end.to(change { File.exist?("xref_error.err.html") }
              .from(false).to(true))
    end
  end

  it "Warns of image names not compliant with DRG" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :docnumber: 1000
      :partnumber: 1
      :edition: 2
      :amendment-number: 3
      :data-uri-image: false
      :updates: ISO 1000:2007
      :doctype: amendment

      .Split-it-right sample divider
      image::spec/examples/rice_img/rice_image1.png[]
      image::spec/examples/rice_img/SL1000-1_ed2amd3fig1.png[]
      image::spec/examples/rice_img/1001_ed2amd3fig1.png[]
      image::spec/examples/rice_img/ISO_1213_1.png[]
      image::spec/examples/rice_img/1000-1_ed2amd3figA.png[]

      |===
      |a |b

      a|image::spec/examples/rice_img/1000-1_ed2amd3figTab1.png[]
      a|image::spec/examples/rice_img/1000-1_ed2amd3fig2.png[]
      |===

      image::spec/examples/rice_img/1000-1_ed2amd3figTab2.png[]

      image::spec/examples/rice_img/1000-1_ed2amd3figA1.png[]
      image::spec/examples/rice_img/1000-1_ed2amd3fig1a.png[]

      .Stages of gelatinization
      ====
      image::spec/examples/rice_img/1000-1_ed2amd3fig1b.png[]

      image::spec/examples/rice_img/1000-1_ed2amd3fig4.png[]
      ====

      image::spec/examples/rice_img/1000-1_ed2amd3fig5_f.png[]

      [appendix]
      == Annex
      image::spec/examples/rice_img/1000-1_ed2amd3figA2.png[]
      image::spec/examples/rice_img/1000-1_ed2amd3fig3.png[]

    INPUT
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/rice_image1.png does not match " \
      "DRG requirements: expect 1000-1_ed2amd3fig"
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/1001_ed2amd3fig1.png does not " \
      "match DRG requirements: " \
      "expect 1000-1_ed2amd3fig"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/SL1000-1_ed2amd3fig1.png does not " \
      "match DRG requirements: " \
      "expect 1000-1_ed2amd3fig"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/ISO_1213_1.png does not match DRG " \
      "requirements: expect 1000-1_ed2amd3fig"
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/1000-1_ed2amd3figA.png does not " \
      "match DRG requirements"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/1000-1_ed2amd3figTab1.png does " \
      "not match DRG requirements"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/1000-1_ed2amd3figTab1.png is " \
      "under a table but is not so labelled"
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig2.png is under " \
      "a table but is not so labelled"
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/1000-1_ed2amd3figTab2.png is " \
      "labelled as under a table but is not"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig1.png is " \
      "labelled as under a table but is not"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/1000-1_ed2amd3figA2.png is " \
      "under an annex but is not so labelled"
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig3.png is " \
      "under an annex but is not so labelled"
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/1000-1_ed2amd3figA1.png is " \
      "labelled as under an annex but is not"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig1.png is " \
      "labelled as under an annex but is not"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig1b.png has a " \
      "subfigure letter but is not a subfigure"
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig4.png does not " \
      "have a subfigure letter but is a subfigure"
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig1a.png has a " \
      "subfigure letter but is not a subfigure"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig1.png has a " \
      "subfigure letter but is not a subfigure"
    expect(File.read("test.err.html")).to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig5_f.png expected " \
      "to have suffix _e"
    expect(File.read("test.err.html")).not_to include
    "image name spec/examples/rice_img/1000-1_ed2amd3fig1.png expected " \
      "to have suffix _e"
  end

  it "Warns of illegal doctype" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include "pizza is not a recognised document type"
  end

  it "Warns of illegal stage" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: pizza

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include "Illegal document stage: pizza.00"

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: 70

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include "Illegal document stage: 70.00"

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: 60

      text
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "Illegal document stage: 60.00"
  end

  it "Warns of illegal substage" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: 60
      :docsubstage: pizza

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include "Illegal document stage: 60.pizza"

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: 60
      :docsubstage: 54

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include "Illegal document stage: 60.54"

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: 60
      :docsubstage: 60

      text
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "Illegal document stage: 60.60"
  end

  xit "Warns of illegal iteration" do
    begin
      input = <<~INPUT
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :status: 60
        :iteration: pizza

        text
      INPUT
      expect do
        Asciidoctor.convert(input, *OPTIONS)
      end.to raise_error(StandardError)
    rescue StandardError
    end
    expect(File.read("test.err.html"))
      .to include "IS stage document cannot have iteration"
  end

  it "warns that technical report may contain requirement" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: technical-report

      == Random clause

      The widget is required not to be larger than 15 cm.
    INPUT
    expect(File.read("test.err.html"))
      .to include "Technical Report clause may contain requirement"
  end

  it "warns that introduction may contain requirement" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}
      == Introduction

      The widget is required not to be larger than 15 cm.
    INPUT
    expect(File.read("test.err.html"))
      .to include "Introduction may contain requirement"
  end

  it "warns that foreword may contain recommendation" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      It is not recommended that widgets should be larger than 15 cm.

      == Clause
    INPUT
    expect(File.read("test.err.html"))
      .to include "Foreword may contain recommendation"
  end

  it "warns that foreword may contain permission" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      No widget is required to be larger than 15 cm.

      == Clause
    INPUT
    expect(File.read("test.err.html"))
      .to include "Foreword may contain permission"
  end

  it "warns that scope may contain recommendation" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Scope
      It is not recommended that widgets should be larger than 15 cm.
    INPUT
    expect(File.read("test.err.html"))
      .to include "Scope may contain recommendation"
  end

  it "warns that definition may contain requirement" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Terms and Definitions

      === Term1

      It is required that there is a definition.

    INPUT
    expect(File.read("test.err.html"))
      .to include "Definition may contain requirement"
  end

  it "warns that term example may contain recommendation" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Terms and Definitions

      === Term

      [example]
      It is not recommended that widgets should be larger than 15 cm.
    INPUT
    expect(File.read("test.err.html"))
      .to include "Example may contain recommendation"
  end

  it "warns that note may contain recommendation" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      NOTE: It is not recommended that widgets should be larger than 15 cm.
    INPUT
    expect(File.read("test.err.html"))
      .to include "Note may contain recommendation"
  end

  it "warns that footnote may contain recommendation" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      footnote:[It is not recommended that widgets should be larger than 15 cm.]
    INPUT
    expect(File.read("test.err.html"))
      .to include "Footnote may contain recommendation"
  end

  it "warns that term source is not in expected format" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [.source]
      I am a generic paragraph
    INPUT
    expect(File.read("test.err.html"))
      .to include "term reference not in expected format"
  end

  it "warns that figure does not have title" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      image::spec/examples/rice_img/rice_image1.png[]
    INPUT
    expect(File.read("test.err.html")).to include "Figure should have title"
  end

  it "warns that term source is not a real reference" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [.source]
      <<iso123>>
    INPUT
    expect(File.read("test.err.html"))
      .to include "iso123 does not have a corresponding anchor ID " \
                  "in the bibliography"
  end

  it "warns that undated reference has locality" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Scope
      <<iso123,clause=1>>

      [bibliography]
      == Normative References
      * [[[iso123,ISO 123]]] _Standard_
    INPUT
    expect(File.read("test.err.html"))
      .to include "undated reference ISO 123 should not contain " \
                  "specific elements"
  end

  it "do not warn that undated reference which is a bibliographic reference " \
     "has locality" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Scope
      <<iso123,clause=1>>

      [bibliography]
      == Bibliography
      * [[[iso123,1]]] _Standard_
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "undated reference [1] should not contain specific " \
                      "elements"
  end

  it "do not warn that undated IEV reference has locality" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Scope
      <<iev,clause=1>>

      [bibliography]
      == Normative References
      * [[[iev,IEV]]] _Standard_
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "undated reference IEV should not contain specific " \
                      "elements"
  end

  it "do not warn that in print has locality" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Scope
      <<iev,clause=1>>

      [bibliography]
      == Normative References
      * [[[iev,ISO 123:--]]] _Standard_
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "undated reference ISO 123 should not contain specific " \
                      "elements"
  end

  it "warns of Non-reference in bibliography" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Normative References
      * I am not a reference
    INPUT
    expect(File.read("test.err.html")).to include "no anchor on reference"
  end

  it "warns of Non-ISO reference in Normative References" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [bibliography]
      == Normative References
      * [[[XYZ,IESO 121]]] _Standard_
    INPUT
    expect(File.read("test.err.html"))
      .to include "non-ISO/IEC reference not expected as normative"
  end

  it "warns that Table should have title" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      |===
      |a |b |c
      |===
    INPUT
    expect(File.read("test.err.html")).to include "Table should have title"
  end

  it "gives Style warning if number not broken up in threes" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      12121
      12121
    INPUT
    r = File.read("test.err.html")
    expect(r).to include "number not broken up in threes"
    expect(r.scan(/number not broken up in threes/).length).to be 1

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      stem:[12121]
    INPUT
    r = File.read("test.err.html")
    expect(r).not_to include "number not broken up in threes"
  end

  it "gives Style warning if number not broken up in threes looks like year" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      1950
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "number not broken up in threes"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR.sub(':nodoc:', ":validate-years:\n  :nodoc:")}

      == Clause
      1950
    INPUT
    expect(File.read("test.err.html"))
      .to include "number not broken up in threes"
  end

  it "gives No style warning if number not broken up in threes is " \
     "ISO reference" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      ISO 12121
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "number not broken up in threes"
  end

  it "Style warning if decimal point" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      8.1
      8.1
    INPUT
    r = File.read("test.err.html")
    expect(r).to include "possible decimal point"
    expect(r.scan(/possible decimal point/).length).to be 1

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      and 8.1
    INPUT
    expect(File.read("test.err.html")).to include "possible decimal point"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      e8.1
    INPUT
    expect(File.read("test.err.html")).not_to include "possible decimal point"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      8.1.1
    INPUT
    expect(File.read("test.err.html")).not_to include "possible decimal point"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      stem:[8.1]
    INPUT
    expect(File.read("test.err.html")).not_to include "possible decimal point"
  end

  it "Style warning if billion used" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      "Billions" are a term of art.
    INPUT
    expect(File.read("test.err.html")).to include "ambiguous number"
  end

  it "Style warning if no space before percent sign" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      95%
    INPUT
    expect(File.read("test.err.html")).to include "no space before percent sign"
  end

  it "Style warning if unbracketed tolerance before percent sign" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      95 ± 5 %
    INPUT
    expect(File.read("test.err.html"))
      .to include "unbracketed tolerance before percent sign"
  end

  it "Style warning if dots in abbreviation" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      r.p.m.
    INPUT
    expect(File.read("test.err.html")).to include "no dots in abbreviation"
  end

  it "No Style warning if dots in abbreviation are e.g." do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      e.g. 5
    INPUT
    expect(File.read("test.err.html")).not_to include "no dots in abbreviation"
  end

  it "Style warning if ppm used" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      5 ppm
    INPUT
    expect(File.read("test.err.html"))
      .to include "language-specific abbreviation"
  end

  it "Style warning if space between number and degree" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      5 °
    INPUT
    expect(File.read("test.err.html"))
      .to include "space between number and degrees/​minutes/​seconds"
  end

  it "Style warning if hyphen instead of minus sign" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      -2
    INPUT
    expect(File.read("test.err.html"))
      .to include "hyphen instead of minus sign U+2212"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      and -2
    INPUT
    expect(File.read("test.err.html"))
      .to include "hyphen instead of minus sign U+2212"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      1-2
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "hyphen instead of minus sign U+2212"
  end

  it "Style warning if no space between number and SI unit" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      A measurement of 5Bq was taken.
    INPUT
    expect(File.read("test.err.html"))
      .to include "no space between number and SI unit"
  end

  it "Style warning if mins used" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      5 mins
    INPUT
    expect(File.read("test.err.html")).to include "non-standard unit"
  end

  it "Style warning if and/or used" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      7 and/or 8
    INPUT
    expect(File.read("test.err.html")).to include "Use 'either x or y, or both'"
  end

  it "Style warning if & used" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      7 & 8
    INPUT
    expect(File.read("test.err.html"))
      .to include "Avoid ampersand in ordinary text"
  end

  it "Style warning if full stop used in title or caption" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause.

      .Table.
      |===
      | A |B
      |===

      === Clause 2.

      .Figure.
      ....
      Z
      ....

      .Other Figure
      ....
      A
      ....
    INPUT
    expect(File.read("test.err.html"))
      .to include "No full stop at end of title or caption: Clause."
    expect(File.read("test.err.html"))
      .to include "No full stop at end of title or caption: Clause 2."
    expect(File.read("test.err.html"))
      .to include "No full stop at end of title or caption: Table."
    expect(File.read("test.err.html"))
      .to include "No full stop at end of title or caption: Figure."
    expect(File.read("test.err.html"))
      .not_to include "No full stop at end of title or caption: Other Figure."
  end

  it "Warning if English title intro and no French title intro" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-intro-en: Title
      :no-isobib:

    INPUT
    expect(File.read("test.err.html")).to include "No French Title Intro"
  end

  it "Warning if French title intro and no English title intro" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-intro-fr: Title
      :no-isobib:

    INPUT
    expect(File.read("test.err.html")).to include "No English Title Intro"
  end

  it "Warning if English title and no French title" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-main-en: Title
      :no-isobib:

    INPUT
    expect(File.read("test.err.html")).to include "No French Title"
    expect(File.read("test.err.html")).not_to include "No French Intro"
  end

  it "Warning if French title and no English title" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-main-fr: Title
      :no-isobib:

    INPUT
    expect(File.read("test.err.html")).to include "No English Title"
  end

  it "Warning if English title part and no French title part" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-part-en: Title
      :no-isobib:

    INPUT
    expect(File.read("test.err.html")).to include "No French Title Part"
  end

  it "Warning if French title part and no English title part" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-part-fr: Title
      :no-isobib:

    INPUT
    expect(File.read("test.err.html")).to include "No English Title Part"
  end

  it "No warning if French main title and English main title" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-part-fr: Title
      :title-part-en: Title
      :no-isobib:

    INPUT
    expect(File.read("test.err.html")).not_to include "No French Title Intro"
    expect(File.read("test.err.html")).not_to include "No French Title Part"
  end

  it "Warning if non-IEC document with subpart" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :docnumber: 10
      :partnumber: 1-1
      :publisher: ISO
      :no-isobib:

    INPUT
    expect(File.read("test.err.html"))
      .to include "Subpart defined on non-IEC document"
  end

  it "No warning if joint IEC/non-IEC document with subpart" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :docnumber: 10
      :partnumber: 1-1
      :publisher: ISO;IEC
      :no-isobib:

    INPUT
    expect(File.read("test.err.html"))
      .not_to include "Subpart defined on non-IEC document"
  end

  it "Warning if main title contains document type" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-main-en: A Technical Specification on Widgets
      :no-isobib:

    INPUT
    expect(File.read("test.err.html"))
      .to include "Main Title may name document type"
  end

  it "Warning if intro title contains document type" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-intro-en: A Technical Specification on Widgets
      :no-isobib:

    INPUT
    expect(File.read("test.err.html"))
      .to include "Title Intro may name document type"
  end

  it "Warning if invalid technical committee type" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :technical-committee: A
      :technical-committee-type: X
      :technical-committee-number: X
      :no-isobib:

    INPUT
    expect(File.read("test.err.html"))
      .to include "invalid technical committee type"
  end

  it "Warning if invalid subcommittee type" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :subcommittee: A
      :subcommittee-type: X
      :subcommittee-number: X
      :no-isobib:

    INPUT
    expect(File.read("test.err.html")).to include "invalid subcommittee type"
  end

  it "Do not warn if 'see' crossreference points to normative section" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}
      [[terms]]
      == Terms and Definitions

      == Clause
      See <<terms>>
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "'see terms' is pointing to a normative section"
  end

  it "Warning if 'see' reference points to normative reference" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}
      [bibliography]
      == Normative References
      * [[[terms,ISO 1]]] _References_

      == Clause
      See <<terms>>
    INPUT
    expect(File.read("test.err.html"))
      .to include "is pointing to a normative reference"
  end

  it "Warning if term definition starts with article" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Term

      The definition of a term is a part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err.html"))
      .to include "term definition starts with article"
  end

  it "Warning if term definition ends with period" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Term

      Part of the specialized vocabulary of a particular field.
    INPUT
    expect(File.read("test.err.html"))
      .to include "term definition ends with period"
  end

  it "validates document against ISO XML schema" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [align=mid-air]
      Para
    INPUT
    expect(File.read("test.err.html"))
      .to include 'value of attribute "align" is invalid; must be equal to'
  end

  it "Warn if an undated reference has no associated footnote" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [bibliography]
      == Bibliography
      * [[[ISO8,ISO 8:--]]], _Title_
    INPUT
    expect(File.read("test.err.html"))
      .to include "Reference ISO8 does not have an associated footnote " \
                  "indicating unpublished status"
  end

  it "Warn if no colon or full stop before list" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      X

      * A very long
      * B list
      * C
    INPUT
    expect(File.read("test.err.html"))
      .to include "All lists must be preceded by colon or full stop"
  end

  it "Do not warn if colon or full stop before list" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      X.

      * A very long
      * B list
      * C

      X:

      . A very long
      . B list
      . C
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "All lists must be preceded by colon or full stop"
  end

  it "Warn of list punctuation after colon" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      X:

      * this is;
      * another broken up;
      * Sentence.

      X:

      . this is
      . another broken up;
      . sentence

      X:

      . sentence.

      X:

      . This is.
      . Another broken up.
      . Sentence.
    INPUT
    expect(File.read("test.err.html"))
      .to include "List entry of broken up sentence must start with " \
                  "lowercase letter: Sentence."
    expect(File.read("test.err.html"))
      .not_to include "List entry of broken up sentence must start with " \
                      "lowercase letter: another broken up;."
    expect(File.read("test.err.html"))
      .to include "List entry of broken up sentence must end with semicolon: " \
                  "this is"
    expect(File.read("test.err.html"))
      .to include "Final list entry of broken up sentence must end with " \
                  "full stop: sentence"
    expect(File.read("test.err.html"))
      .not_to include "Final list entry of broken up sentence must end with " \
                      "full stop: sentence."
    expect(File.read("test.err.html"))
      .not_to include "List entry of broken up sentence must start with " \
                      "lowercase letter: Another broken up."
    expect(File.read("test.err.html"))
      .not_to include "List entry of broken up sentence must end with " \
                      "semicolon: This is."
  end

  it "Warn of list punctuation after full stop" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      X.

      * This is;
      * Another broken up.
      * sentence.

    INPUT
    expect(File.read("test.err.html"))
      .to include "List entry of separate sentences must end with full stop: " \
                  "This is;"
    expect(File.read("test.err.html"))
      .not_to include "List entry of separate sentences must end with " \
                      "full stop: Another broken up."
    expect(File.read("test.err.html"))
      .to include "List entry of separate sentences must start with " \
                  "uppercase letter: sentence."
  end

  it "Skips punctuation check for short entries in lists" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      X.

      * This is
      * Another
      * sentence

    INPUT
    expect(File.read("test.err.html"))
      .not_to include "List entry after full stop must end with full stop: " \
                      "This is"
  end

  it "Skips punctuation check for lists within tables" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      |===
      | A
      a|
      * This is
      * Another
      * sentence
      |===

    INPUT
    expect(File.read("test.err.html"))
      .not_to include "List entry after full stop must end with full stop: " \
                      "This is"
  end

  it "Warn if more than one ordered lists in a clause" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      . A
      .. B
      ... C

      a

      . A
      .. B

      a

      . B

    INPUT
    expect(File.read("test.err.html"))
      .to include "More than 1 ordered list in a numbered clause"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      . A
      .. B
      ... C

      === Clause
      a

      . A
      .. B

      a

    INPUT
    expect(File.read("test.err.html"))
      .not_to include "More than 1 ordered list in a numbered clause"
  end

  it "Warn if list more than four levels deep" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      . A
      .. B
      ... C
      .... D

    INPUT
    expect(File.read("test.err.html"))
      .not_to include "List more than four levels deep"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      . A
      .. B
      ... C
      .... D
      ..... E

    INPUT
    expect(File.read("test.err.html"))
      .to include "List more than four levels deep"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      * A
      ** B
      *** C
      **** D
      ***** E

    INPUT
    expect(File.read("test.err.html"))
      .to include "List more than four levels deep"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      * A
      .. B
      *** C
      .... D
      ***** E

    INPUT
    expect(File.read("test.err.html"))
      .to include "List more than four levels deep"
  end

  it "warn if term clause crossreferences non-term reference" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Terms and definitions

      [[b]]
      === Term 1
      <<b>>
      <<c>>

      [[c]]
      == Clause

    INPUT
    expect(File.read("test.err.html"))
      .to include "non-terms clauses cannot cross-reference terms clause (c)"
    expect(File.read("test.err.html"))
      .not_to include "non-terms clauses cannot cross-reference terms " \
                      "clause (b)"
  end

  it "warn if non-term clause crossreferences term reference" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Terms and definitions

      [[b]]
      === Term 1
      _<<b>>_
      _<<c>>_

      == Clause
      _<<b>>_
      _<<c>>_

    INPUT
    expect(File.read("test.err.html"))
      .to include "only terms clauses can cross-reference terms clause (b)"
    expect(File.read("test.err.html"))
      .not_to include "only terms clauses can cross-reference terms clause (c)"
  end

  it "warns of explicit style set on ordered list" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      [arabic]
      . A
    INPUT
    expect(File.read("test.err.html"))
      .to include "Style override set for ordered list"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      . A
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "Style override set for ordered list"
  end

  it "warns of ambiguous provision term" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      Might I trouble you?
    INPUT
    expect(File.read("test.err.html"))
      .to include "may contain ambiguous provision"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      I won't trouble you.
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "may contain ambiguous provision"
  end

  it "warns of nested subscripts" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      +++Y<sub>n<sub>1</sub></sub>+++

    INPUT
    expect(File.read("test.err.html"))
      .to include "may contain nested subscripts (max 3 levels allowed)"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      [stem]
      ++++
      a_(n_1)
      ++++

    INPUT
    expect(File.read("test.err.html"))
      .to include "may contain nested subscripts (max 3 levels allowed)"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      +++Y<sub>n</sub>+++
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "may contain nested subscripts (max 3 levels allowed)"
  end

  it "warns of cross-references before punctuation" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      <<a,fn:>>.

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(File.read("test.err.html"))
      .to include "superscript cross-reference followed by punctuation"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      <<a,fn:>>,

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(File.read("test.err.html"))
      .to include "superscript cross-reference followed by punctuation"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      <<a>>.

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "superscript cross-reference followed by punctuation"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      <<a,fn:>>

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "superscript cross-reference followed by punctuation"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      , <<a,fn:>> A

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(File.read("test.err.html"))
      .not_to include "superscript cross-reference followed by punctuation"
  end
end
