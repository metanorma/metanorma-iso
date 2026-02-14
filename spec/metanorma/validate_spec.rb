require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Iso, type: :validation do
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
    errors = convert_and_capture_errors(<<~INPUT)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza

      text
    INPUT
    expect(errors).to include("pizza is not a recognised document type")
  end

  context "Stage validation" do
    let(:illegal_stage_pizza) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :status: pizza

        text
      INPUT
    end

    let(:illegal_stage_70) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :status: 70

        text
      INPUT
    end

    let(:legal_stage_60) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :status: 60

        text
      INPUT
    end

    it "Warns of illegal stage" do
      expect(illegal_stage_pizza).to include("Illegal document stage: pizza.00")
      expect(illegal_stage_70).to include("Illegal document stage: 70.00")
      expect(legal_stage_60).not_to include("Illegal document stage: 60.00")
    end
  end

  context "Substage validation" do
    let(:illegal_substage_pizza) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :status: 60
        :docsubstage: pizza

        text
      INPUT
    end

    let(:illegal_substage_54) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :status: 60
        :docsubstage: 54

        text
      INPUT
    end

    let(:legal_substage_60) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :status: 60
        :docsubstage: 60

        text
      INPUT
    end

    it "Warns of illegal substage" do
      expect(illegal_substage_pizza).to include("Illegal document stage: 60.pizza")
      expect(illegal_substage_54).to include("Illegal document stage: 60.54")
      expect(legal_substage_60).not_to include("Illegal document stage: 60.60")
    end
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
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      [.source]
      I am a generic paragraph
    INPUT
    expect(errors).to include("term reference not in expected format")
  end

  it "warns that figure does not have title" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      image::spec/examples/rice_img/rice_image1.png[]
    INPUT
    expect(errors).to include("Figure should have title")
  end

  it "warns that term source is not a real reference" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      [.source]
      <<iso123>>
    INPUT
    expect(errors).to include("iso123 does not have a corresponding anchor ID in the bibliography")
  end

  it "warns that undated reference has locality" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Scope
      <<iso123,clause=1>>

      [bibliography]
      == Normative References
      * [[[iso123,ISO 123]]] _Standard_
    INPUT
    expect(errors).to include("123")
  end

  it "do not warn that undated reference which is a bibliographic reference has locality" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Scope
      <<iso123,clause=1>>

      [bibliography]
      == Bibliography
      * [[[iso123,1]]] _Standard_
    INPUT
    expect(errors).not_to include("undated reference [1] should not contain specific elements")
  end

  it "do not warn that undated IEV reference has locality" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Scope
      <<iev,clause=1>>

      [bibliography]
      == Normative References
      * [[[iev,IEV]]] _Standard_
    INPUT
    expect(errors).not_to include("undated reference IEV should not contain specific elements")
  end

  it "do not warn that in print has locality" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Scope
      <<iev,clause=1>>

      [bibliography]
      == Normative References
      * [[[iev,ISO 123:--]]] _Standard_
    INPUT
    expect(errors).not_to include("undated reference ISO 123 should not contain specific elements")
  end

  it "warns of Non-reference in bibliography" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Normative References
      * I am not a reference
    INPUT
    expect(errors).to include("no anchor on reference")
  end

  it "warns of Non-ISO reference in Normative References" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      [bibliography]
      == Normative References
      * [[[XYZ,IESO 121]]] _Standard_
    INPUT
    expect(errors).to include("non-ISO/IEC reference is allowed as normative only subject to the conditions in ISO/IEC DIR 2 10.2")
  end

  it "warns that Table should have title" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      |===
      |a |b |c
      |===
    INPUT
    expect(errors).to include("Table should have title")
  end

  context "Title language warnings" do
    let(:english_intro_no_french) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :title-intro-en: Title
        :no-isobib:

      INPUT
    end

    let(:french_intro_no_english) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :title-intro-fr: Title
        :no-isobib:

      INPUT
    end

    let(:english_main_no_french) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :title-main-en: Title
        :no-isobib:

      INPUT
    end

    let(:french_main_no_english) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :title-main-fr: Title
        :no-isobib:

      INPUT
    end

    let(:english_part_no_french) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :title-part-en: Title
        :no-isobib:

      INPUT
    end

    let(:french_part_no_english) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :title-part-fr: Title
        :no-isobib:

      INPUT
    end

    let(:both_parts) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :title-part-fr: Title
        :title-part-en: Title
        :no-isobib:

      INPUT
    end

    it "Warning if English title intro and no French title intro" do
      expect(english_intro_no_french).to include("No French Title Intro")
    end

    it "Warning if French title intro and no English title intro" do
      expect(french_intro_no_english).to include("No English Title Intro")
    end

    it "Warning if English title and no French title" do
      expect(english_main_no_french).to include("No French Title")
      expect(english_main_no_french).not_to include("No French Intro")
    end

    it "Warning if French title and no English title" do
      expect(french_main_no_english).to include("No English Title")
    end

    it "Warning if English title part and no French title part" do
      expect(english_part_no_french).to include("No French Title Part")
    end

    it "Warning if French title part and no English title part" do
      expect(french_part_no_english).to include("No English Title Part")
    end

    it "No warning if French main title and English main title" do
      expect(both_parts).not_to include("No French Title Intro")
      expect(both_parts).not_to include("No French Title Part")
    end
  end

  it "Warning if non-IEC document with subpart" do
    errors = convert_and_capture_errors(<<~INPUT)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :docnumber: 10
      :partnumber: 1-1
      :publisher: ISO
      :no-isobib:

    INPUT
    expect(errors).to include("Subpart defined on non-IEC document")
  end

  it "No warning if joint IEC/non-IEC document with subpart" do
    errors = convert_and_capture_errors(<<~INPUT)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :docnumber: 10
      :partnumber: 1-1
      :publisher: ISO;IEC
      :no-isobib:

    INPUT
    expect(errors).not_to include("Subpart defined on non-IEC document")
  end

  it "Warning if invalid technical committee type" do
    errors = convert_and_capture_errors(<<~INPUT)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :technical-committee: A
      :technical-committee-type: X
      :technical-committee-number: X
      :no-isobib:

    INPUT
    expect(errors).to include("invalid technical committee type")
  end

  it "Warning if invalid subcommittee type" do
    errors = convert_and_capture_errors(<<~INPUT)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :technical-committee: A1
      :subcommittee: A
      :subcommittee-type: X
      :subcommittee-number: X
      :no-isobib:

    INPUT
    expect(errors).to include("invalid subcommittee type")
  end

  it "validates document against Metanorma XML schema" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      [align=mid-air]
      Para
    INPUT
    expect(errors).to include('value of attribute "align" is invalid; must be equal to')
  end

  it "Warn if an undated reference has no associated footnote" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      [bibliography]
      == Bibliography
      * [[[ISO8,ISO 8:--]]], _Title_
    INPUT
    expect(errors1).to include("Reference does not have an associated footnote indicating unpublished status")

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      [bibliography]
      == Bibliography
      * [[[ISO8,amend(ISO 8)]]], _Title_ span:note.Unpublished-Status,display[Unpub]
    INPUT
    expect(errors2).not_to include("Reference does not have an associated footnote indicating unpublished status")
  end

  it "Warn if more than one ordered lists in a clause" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors1).to include("More than 1 ordered list in a numbered clause")

    errors2 = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors2).not_to include("More than 1 ordered list in a numbered clause")
  end

  context "List depth validation" do
    let(:four_levels) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Clause

        . A
        .. B
        ... C
        .... D

      INPUT
    end

    let(:five_levels_ordered) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Clause

        . A
        .. B
        ... C
        .... D
        ..... E

      INPUT
    end

    let(:five_levels_unordered) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Clause

        * A
        ** B
        *** C
        **** D
        ***** E

      INPUT
    end

    let(:five_levels_mixed) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Clause

        * A
        .. B
        *** C
        .... D
        ***** E

      INPUT
    end

    it "Warn if list more than four levels deep" do
      expect(four_levels).not_to include("List more than four levels deep")
      expect(five_levels_ordered).to include("List more than four levels deep")
      expect(five_levels_unordered).to include("List more than four levels deep")
      expect(five_levels_mixed).to include("List more than four levels deep")
    end
  end

  it "warn if term clause crossreferences non-term reference" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Terms and definitions

      [[b]]
      === Term 1
      <<b>>
      <<c>>

      [[c]]
      == Clause

    INPUT
    expect(errors).to include("non-terms clauses cannot cross-reference terms clause (c)")
    expect(errors).not_to include("non-terms clauses cannot cross-reference terms clause (b)")
  end

  it "warn if non-term clause crossreferences term reference" do
    errors = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors).to include("only terms clauses can cross-reference terms clause (b)")
    expect(errors).not_to include("only terms clauses can cross-reference terms clause (c)")
  end

  context "Nested subscripts validation" do
    let(:two_level_html) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Clause
        +++Y<sub>n<sub>1</sub></sub>+++

      INPUT
    end

    let(:three_level_html) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Clause
        +++Y<sub>n<sub>1<sub>2</sub></sub></sub>+++

      INPUT
    end

    let(:four_level_html) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Clause
        +++Y<sub>n<sub>1<sub>2<sub>3</sub></sub></sub></sub>+++

      INPUT
    end

    let(:two_level_mathml) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Clause
        [stem]
        ++++
        a_(n_1)
        ++++

      INPUT
    end

    let(:single_level) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Clause
        +++Y<sub>n</sub>+++
      INPUT
    end

    it "warns of nested subscripts" do
      # Test 2-level nesting (should warn with "may contain nested subscripts")
      expect(two_level_html).to include("may contain nested subscripts")
      expect(two_level_html).not_to include("no more than 3 levels of nesting allowed")

      # Test 3-level nesting (should warn with "may contain nested subscripts")
      expect(three_level_html).to include("may contain nested subscripts")
      expect(three_level_html).not_to include("no more than 3 levels of nesting allowed")

      # Test 4-level nesting (should warn with "no more than 3 levels of nesting allowed")
      expect(four_level_html).not_to include("may contain nested subscripts")
      expect(four_level_html).to include("no more than 3 levels of subscript nesting allowed")

      # Test MathML 2-level nesting
      expect(two_level_mathml).to include("may contain nested subscripts")
      expect(two_level_mathml).not_to include("no more than 3 levels of nesting allowed")

      # Test single level subscript (should not warn)
      expect(single_level).not_to include("may contain nested subscripts")
      expect(single_level).not_to include("no more than 3 levels of nesting allowed")
    end

    it "does not trigger warnings on inner elements" do
      # Should only have one warning (from the topmost sub)
      warning_count = four_level_html.scan(/no more than 3 levels of subscript nesting allowed/).length
      expect(warning_count).to eq(1)
    end
  end
end
