require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Iso do
  before do
    FileUtils.rm_rf("test.err.html")
  end

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
      .to include("pizza is not a recognised document type")
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
      .to include("Illegal document stage: pizza.00")

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
      .to include("Illegal document stage: 70.00")

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
      .not_to include("Illegal document stage: 60.00")
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
      .to include("Illegal document stage: 60.pizza")

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
      .to include("Illegal document stage: 60.54")

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
      .not_to include("Illegal document stage: 60.60")
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
      .to include("IS stage document cannot have iteration")
  end

  it "warns that term source is not in expected format" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [.source]
      I am a generic paragraph
    INPUT
    expect(File.read("test.err.html"))
      .to include("term reference not in expected format")
  end

  it "warns that figure does not have title" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      image::spec/examples/rice_img/rice_image1.png[]
    INPUT
    expect(File.read("test.err.html")).to include("Figure should have title")
  end

  it "warns that term source is not a real reference" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [.source]
      <<iso123>>
    INPUT
    expect(File.read("test.err.html"))
      .to include("iso123 does not have a corresponding anchor ID " \
                  "in the bibliography")
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
      .to include("undated reference ISO 123 should not contain " \
                  "specific elements")
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
      .not_to include("undated reference [1] should not contain specific " \
                      "elements")
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
      .not_to include("undated reference IEV should not contain specific " \
                      "elements")
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
      .not_to include("undated reference ISO 123 should not contain specific " \
                      "elements")
  end

  it "warns of Non-reference in bibliography" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Normative References
      * I am not a reference
    INPUT
    expect(File.read("test.err.html")).to include("no anchor on reference")
  end

  it "warns of Non-ISO reference in Normative References" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [bibliography]
      == Normative References
      * [[[XYZ,IESO 121]]] _Standard_
    INPUT
    expect(File.read("test.err.html"))
      .to include("non-ISO/IEC reference not expected as normative")
  end

  it "warns that Table should have title" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      |===
      |a |b |c
      |===
    INPUT
    expect(File.read("test.err.html")).to include("Table should have title")
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
    expect(File.read("test.err.html")).to include("No French Title Intro")
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
    expect(File.read("test.err.html")).to include("No English Title Intro")
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
    expect(File.read("test.err.html")).to include("No French Title")
    expect(File.read("test.err.html")).not_to include("No French Intro")
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
    expect(File.read("test.err.html")).to include("No English Title")
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
    expect(File.read("test.err.html")).to include("No French Title Part")
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
    expect(File.read("test.err.html")).to include("No English Title Part")
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
    expect(File.read("test.err.html")).not_to include("No French Title Intro")
    expect(File.read("test.err.html")).not_to include("No French Title Part")
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
      .to include("Subpart defined on non-IEC document")
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
      .not_to include("Subpart defined on non-IEC document")
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
      .to include("invalid technical committee type")
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
    expect(File.read("test.err.html")).to include("invalid subcommittee type")
  end

  it "validates document against Metanorma XML schema" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [align=mid-air]
      Para
    INPUT
    expect(File.read("test.err.html"))
      .to include('value of attribute "align" is invalid; must be equal to')
  end

  it "Warn if an undated reference has no associated footnote" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      [bibliography]
      == Bibliography
      * [[[ISO8,ISO 8:--]]], _Title_
    INPUT
    expect(File.read("test.err.html"))
      .to include("Reference ISO8 does not have an associated footnote " \
                  "indicating unpublished status")
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
      .to include("More than 1 ordered list in a numbered clause")

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
      .not_to include("More than 1 ordered list in a numbered clause")
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
      .not_to include("List more than four levels deep")

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
      .to include("List more than four levels deep")

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
      .to include("List more than four levels deep")

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
      .to include("List more than four levels deep")
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
      .to include("non-terms clauses cannot cross-reference terms clause (c)")
    expect(File.read("test.err.html"))
      .not_to include("non-terms clauses cannot cross-reference terms " \
                      "clause (b)")
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
      .to include("only terms clauses can cross-reference terms clause (b)")
    expect(File.read("test.err.html"))
      .not_to include("only terms clauses can cross-reference terms clause (c)")
  end

  it "warns of nested subscripts" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      +++Y<sub>n<sub>1</sub></sub>+++

    INPUT
    expect(File.read("test.err.html"))
      .to include("may contain nested subscripts (max 3 levels allowed)")

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      [stem]
      ++++
      a_(n_1)
      ++++

    INPUT
    expect(File.read("test.err.html"))
      .to include("may contain nested subscripts (max 3 levels allowed)")

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      +++Y<sub>n</sub>+++
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("may contain nested subscripts (max 3 levels allowed)")
  end
end
