require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Iso, type: :validation do
  before do
    FileUtils.rm_rf("test.err.html")
  end

  it "warns that technical report may contain requirement" do
    errors = convert_and_capture_errors(<<~INPUT)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: technical-report

      == Random clause

      The widget is required not to be larger than 15 cm.
    INPUT
    expect(errors).to include("Technical Report clause may contain requirement")
  end

  it "warns that introduction may contain requirement" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}
      == Introduction

      The widget is required not to be larger than 15 cm.
    INPUT
    expect(errors).to include("Introduction may contain requirement")
  end

  it "warns that foreword may contain recommendation" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      It is not recommended that widgets should be larger than 15 cm.

      == Clause
    INPUT
    expect(errors).to include("Foreword may contain recommendation")
  end

  it "warns that foreword may contain permission" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      No widget is required to be larger than 15 cm.

      == Clause
    INPUT
    expect(errors).to include("Foreword may contain permission")
  end

  it "warns that scope may contain recommendation" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Scope
      It is not recommended that widgets should be larger than 15 cm.
    INPUT
    expect(errors).to include("Scope may contain recommendation")
  end

  it "warns that definition may contain requirement" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Terms and Definitions

      === Term1

      It is required that there is a definition.

    INPUT
    expect(errors).to include("Definition may contain requirement")
  end

  it "warns that term example may contain recommendation" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Terms and Definitions

      === Term

      [example]
      It is not recommended that widgets should be larger than 15 cm.
    INPUT
    expect(errors).to include("Example may contain recommendation")
  end

  it "warns that note may contain recommendation" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      NOTE: It is not recommended that widgets should be larger than 15 cm.
    INPUT
    expect(errors).to include("Note may contain recommendation")
  end

  it "warns that footnote may contain recommendation" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      footnote:[It is not recommended that widgets should be larger than 15 cm.]
    INPUT
    expect(errors).to include("Footnote may contain recommendation")
  end

  it "gives Style warning if number not broken up in threes" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      12121
      12121
    INPUT
    expect(errors1).to include("number not broken up in threes")
    expect(errors1.scan(/number not broken up in threes/).length).to be 1

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      stem:[12121]
    INPUT
    expect(errors2).not_to include("number not broken up in threes")

    errors3 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause

      ====
      12121
      ====
    INPUT
    expect(errors3).to include("number not broken up in threes")

    errors4 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause

      ====
      ----
      12121
      ----
      ====
    INPUT
    expect(errors4).not_to include("number not broken up in threes")

    errors5 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause

      ====
      12121
      ----
      12121
      ----
      ====
    INPUT
    expect(errors5).to include("number not broken up in threes")
  end

  it "gives Style warning if number not broken up in threes looks like year" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      1950
    INPUT
    expect(errors1).not_to include("number not broken up in threes")

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR.sub(':nodoc:', ":validate-years:  \n:nodoc:")}

      == Clause
      1950
    INPUT
    expect(errors2).to include("number not broken up in threes")
  end

  it "gives No style warning if number not broken up in threes is ISO reference" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      ISO 12121
    INPUT
    expect(errors).not_to include("number not broken up in threes")
  end

  it "Style warning if decimal point" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      8.1
      8.1
    INPUT
    expect(errors1).to include("possible decimal point")
    expect(errors1.scan(/possible decimal point/).length).to be 1

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      and 8.1
    INPUT
    expect(errors2).to include("possible decimal point")

    errors3 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      e8.1
    INPUT
    expect(errors3).not_to include("possible decimal point")

    errors4 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      8.1.1
    INPUT
    expect(errors4).not_to include("possible decimal point")

    errors5 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      stem:[8.1]
    INPUT
    expect(errors5).not_to include("possible decimal point")
  end

  it "Style warning if billion used" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      "Billions" are a term of art.
    INPUT
    expect(errors).to include("ambiguous number")
  end

  it "Style warning if no space before percent sign" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      95%
    INPUT
    expect(errors).to include("no space before percent sign")
  end

  it "Style warning if unbracketed tolerance before percent sign" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      95 ± 5 %
    INPUT
    expect(errors).to include("unbracketed tolerance before percent sign")
  end

  it "Style warning if dots in abbreviation" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      r.p.m.
    INPUT
    expect(errors).to(include "no dots in abbreviation")
  end

  it "No Style warning if dots in abbreviation are e.g." do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      e.g. 5
    INPUT
    expect(errors).not_to include("no dots in abbreviation")
  end

  it "Style warning if ppm used" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      5 ppm
    INPUT
    expect(errors1).to include("language-specific abbreviation")

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      ppm
    INPUT
    expect(errors2).not_to include("language-specific abbreviation")
  end

  it "Style warning if space between number and degree" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      5 °
    INPUT
    expect(errors).to include("space between number and degrees/​minutes/​seconds")
  end

  it "Style warning if hyphen instead of minus sign" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      -2
    INPUT
    expect(errors1).to include("hyphen instead of minus sign U+2212")

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      and -2
    INPUT
    expect(errors2).to include("hyphen instead of minus sign U+2212")

    errors3 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      1-2
    INPUT
    expect(errors3).not_to include("hyphen instead of minus sign U+2212")
  end

  it "Style warning if no space between number and SI unit" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      A measurement of 5Bq was taken.
    INPUT
    expect(errors1).to include("no space between number and SI unit")

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      A measurement of U+05Bq was taken.
    INPUT
    expect(errors2).not_to include("no space between number and SI unit")

    errors3 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      A measurement of 05Bq was taken.
    INPUT
    expect(errors3).not_to include("no space between number and SI unit")
  end

  it "Style warning if mins used" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      5 mins
    INPUT
    expect(errors).to include("non-standard unit")
  end

  it "Style warning if and/or used" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      7 and/or 8
    INPUT
    expect(errors).to include("Use 'either x or y, or both'")
  end

  it "Style warning if & used" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      7 & 8
    INPUT
    expect(errors).to include("Avoid ampersand in ordinary text")
  end

  it "Style warning if full stop used in title or caption" do
    errors = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors).to include("No full stop at end of title or caption: Clause.")
    expect(errors).to include("No full stop at end of title or caption: Clause 2.")
    expect(errors).to include("No full stop at end of title or caption: Table.")
    expect(errors).to include("No full stop at end of title or caption: Figure.")
    expect(errors).not_to include("No full stop at end of title or caption: Other Figure.")
  end

  it "Warning if main title contains document type" do
    errors = convert_and_capture_errors(<<~INPUT)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-main-en: A Technical Specification on Widgets
      :no-isobib:

    INPUT
    expect(errors).to include("Main Title may name document type")
  end

  it "Warning if intro title contains document type" do
    errors = convert_and_capture_errors(<<~INPUT)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :title-intro-en: A Technical Specification on Widgets
      :no-isobib:

    INPUT
    expect(errors).to include("Title Intro may name document type")
  end

  it "Do not warn if 'see' crossreference points to normative section" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}
      [[terms]]
      == Terms and Definitions

      == Clause
      See <<terms>>
    INPUT
    expect(errors).not_to include("'see terms' is pointing to a normative section")
  end

  it "Warning if 'see' reference points to normative reference" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}
      [bibliography]
      == Normative References
      * [[[terms,ISO 1]]] _References_

      == Clause
      See <<terms>>
    INPUT
    expect(errors).to include("is pointing to a normative reference")
  end

  it "Warning if term definition starts with article" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Term

      The definition of a term is a part of the specialized vocabulary of a particular field
    INPUT
    expect(errors).to include("term definition starts with article")
  end

  it "Warning if term definition ends with period" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Term

      Part of the specialized vocabulary of a particular field.
    INPUT
    expect(errors).to include("term definition ends with period")
  end

  it "Warn if no colon or full stop before list" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause

      X

      * A very long
      * B list
      * C
    INPUT
    expect(errors).to include("All lists must be preceded by colon or full stop")
  end

  it "Do not warn if colon or full stop before list" do
    errors = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors).not_to include("All lists must be preceded by colon or full stop")
  end

  it "Warn of list punctuation after colon" do
    errors = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors).to include("List entry of broken up sentence must start with lowercase letter: Sentence.")
    expect(errors).not_to include("List entry of broken up sentence must start with lowercase letter: another broken up;.")
    expect(errors).to include("List entry of broken up sentence must end with semicolon: this is")
    expect(errors).to include("Final list entry of broken up sentence must end with full stop: sentence")
    expect(errors).not_to include("Final list entry of broken up sentence must end with full stop: sentence.")
    expect(errors).not_to include("List entry of broken up sentence must start with lowercase letter: Another broken up.")
    expect(errors).not_to include("List entry of broken up sentence must end with semicolon: This is.")
  end

  it "Warn of list punctuation after full stop" do
    FileUtils.rm_rf("test.err.html")
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      [[x]]
      == Clause

      X.

      * This is;
      * Another broken up.
      * sentence.
      * <<x,A>> sentence.
      * <<x,b>> sentence.

    INPUT
    expect(errors1).to include("List entry of separate sentences must end with full stop: This is;")
    expect(errors1).not_to include("List entry of separate sentences must end with full stop: Another broken up.")
    expect(errors1).to include("List entry of separate sentences must start with uppercase letter: sentence.")
    expect(errors1).not_to include("List entry of separate sentences must start with uppercase letter: A sentence.")
    expect(errors1).to include("List entry of separate sentences must start with uppercase letter: b sentence.")

    FileUtils.rm_rf("test.err.html")
    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause

      [x]
      === Clause

      X.

      * This is.
      * 32 bytes.
      * stem:[n] bytes.
      * <<x>> bytes.

    INPUT
    expect(errors2).not_to include("List entry of separate sentences must start with uppercase letter")
  end

  it "Skips punctuation check for short entries in lists" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause

      X.

      * This is
      * Another
      * sentence

    INPUT
    expect(errors).not_to include("List entry after full stop must end with full stop: This is")
  end

  it "Skips punctuation check for lists within tables" do
    errors = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors).not_to include("List entry after full stop must end with full stop: This is")
  end

  it "warns of explicit style set on ordered list" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      [arabic]
      . A
    INPUT
    expect(errors1).to include("Style override set for ordered list")

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      . A
    INPUT
    expect(errors2).not_to include("Style override set for ordered list")
  end

  it "warns of ambiguous provision term" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      Might I trouble you?
    INPUT
    expect(errors1).to include("may contain ambiguous provision")

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      I won't trouble you.
    INPUT
    expect(errors2).not_to include("may contain ambiguous provision")

    errors3 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      This is not a suite of standards, but a series.
    INPUT
    expect(errors3).to include("may contain ambiguous provision")
  end

  it "warns of misppelled term" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      Cyber-security is important
    INPUT
    expect(errors1).to include("dispreferred spelling")

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      Cyber
      security is important
    INPUT
    expect(errors2).to include("dispreferred spelling")

    errors3 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      This is not a suite of standards, but a series.
    INPUT
    expect(errors3).not_to include("dispreferred spelling")
  end

  it "warns of cross-references before punctuation" do
    errors1 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      <<a,fn:>>.

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(errors1).to include("superscript cross-reference followed by punctuation")

    errors2 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      <<a,fn:>>,

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(errors2).to include("superscript cross-reference followed by punctuation")

    errors3 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      <<a>>.

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(errors3).not_to include("superscript cross-reference followed by punctuation")

    errors4 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      <<a,fn:>>

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(errors4).not_to include("superscript cross-reference followed by punctuation")

    errors5 = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Clause
      , <<a,fn:>> A

      [bibliography]
      == Bibliography
      * [[[a, b]]]
    INPUT
    expect(errors5).not_to include("superscript cross-reference followed by punctuation")
  end

  it "warns of failures to cross-reference assets" do
    input = <<~INPUT
      #{VALIDATING_BLANK_HDR}

      == Clause

      <<Form01;to!Form03>>

      [[Form01]]
      [stem]
      ++++
      A
      ++++

      [[Form02]]
      [stem]
      ++++
      A
      ++++

      [[Form03]]
      [stem]
      ++++
      A
      ++++

      [[Form1]]
      [stem]
      ++++
      A
      ++++

      [[Form2]]
      [stem%unnumbered]
      ++++
      A
      ++++

      [[Fig1]]
      image::spec/examples/rice_img/1000-1_ed2amd3fig1b.png[]

      [[Fig2]]
      .Stages of gelatinization
      ====
      [[Fig2a]]
      image::spec/examples/rice_img/1000-1_ed2amd3fig1b.png[]

      image::spec/examples/rice_img/1000-1_ed2amd3fig4.png[]
      ====

      [[Fig3]]
      [%unnumbered]
      image::spec/examples/rice_img/1000-1_ed2amd3fig4.png[]

      [[Fig4]]
      [figure]
      ====
      [[Form3]]
      [stem]
      ++++
      A
      ++++
      ====

      [[Tab1]]
      |===
      | A
      a|
      [[Fig5]]
      image::spec/examples/rice_img/1000-1_ed2amd3fig4.png[]

      [[Form4]]
      [stem]
      ++++
      A
      ++++

      |===

      [[Tab2]]
      [%unnumbered]
      |===
      | A
      |===

      [[Ex1]]
      ====
      A
      ====

      [[AnnA]]
      [appendix]
      == Annex A

      [[AnnB]]
      [appendix]
      == Annex B

      [[AnnB1]]
      === Subclause

      [[AnnC]]
      [appendix%unnumbered]
      == Annex C
    INPUT

    f = convert_and_capture_errors(input)
    expect(f).to include("Formula Form1 has not been cross-referenced within document")
    expect(f).not_to include("Formula Form2 has not been cross-referenced within document")
    expect(f).to include("Figure Fig2 has not been cross-referenced within document")
    expect(f).not_to include("Figure Fig2a has not been cross-referenced within document")
    expect(f).not_to include("Figure Fig3 has not been cross-referenced within document")
    expect(f).not_to include("Formula Form3 has not been cross-referenced within document")
    expect(f).to include("Table Tab1 has not been cross-referenced within document")
    expect(f).not_to include("Table Tab2 has not been cross-referenced within document")
    expect(f).not_to include("Formula Form4 has not been cross-referenced within document")
    expect(f).not_to include("Ex1 has not been cross-referenced within document")
    expect(f).to include("Annex AnnA has not been cross-referenced within document")
    expect(f).not_to include("Annex AnnB1 has not been cross-referenced within document")
    expect(f).not_to include("Annex AnnC has not been cross-referenced within document")
    expect(f).not_to include("Formula Form01 has not been cross-referenced within document")
    expect(f).not_to include("Formula Form02 has not been cross-referenced within document")
    expect(f).not_to include("Formula Form03 has not been cross-referenced within document")

    input += <<~INPUT

      == Clause
      <<Form1>>
      <<Form2>>
      <<Fig1>>
      <<Fig2>>
      <<Fig3>>
      <<Fig4>>
      <<Form4>>
      <<Tab1>>
      <<Fig5>>
      <<Form5>>
      <<Tab2>>
      <<Ex1>>
      <<AnnA>>
      <<AnnB>>
      <<AnnB1>>
      <<AnnC>>
    INPUT

    f2 = convert_and_capture_errors(input)
    expect(f2).not_to include("Formula Form1 has not been cross-referenced within document")
    expect(f2).not_to include("Formula Form2 has not been cross-referenced within document")
    expect(f2).not_to include("Figure Fig2 has not been cross-referenced within document")
    expect(f2).not_to include("Figure Fig2a has not been cross-referenced within document")
    expect(f2).not_to include("Figure Fig3 has not been cross-referenced within document")
    expect(f2).not_to include("Formula Form3 has not been cross-referenced within document")
    expect(f2).not_to include("Table Tab1 has not been cross-referenced within document")
    expect(f2).not_to include("Table Tab2 has not been cross-referenced within document")
    expect(f2).not_to include("Formula Form4 has not been cross-referenced within document")
    expect(f2).not_to include("Ex1 has not been cross-referenced within document")
    expect(f2).not_to include("Annex AnnA has not been cross-referenced within document")
    expect(f2).not_to include("Annex AnnB has not been cross-referenced within document")
    expect(f2).not_to include("Annex AnnB1 has not been cross-referenced within document")
    expect(f2).not_to include("Annex AnnC has not been cross-referenced within document")
  end
end
