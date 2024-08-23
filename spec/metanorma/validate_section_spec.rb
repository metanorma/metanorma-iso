require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::ISO do
  context "Warns of missing scope" do
    it "Scope clause missing" do
      Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        text
      INPUT

      expect(File.read("test.err.html")).to include("Scope clause missing")
    end

    it "Scope clause not missing if supplied" do
      Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        == Scope
      INPUT
      expect(File.read("test.err.html")).not_to include("Scope clause missing")
    end

    it "Scope clause not missing in amendments" do
      FileUtils.rm_f "test.err.html"
      Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: amendment

        text
      INPUT
      expect(File.read("test.err.html")).not_to include("Scope clause missing")
    end
  end

  context "Warns of missing normative references" do
    it "Normative references missing" do
      FileUtils.rm_f "test.err.html"
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
        .to include("Normative references missing")
    end

    it "Normative references not missing if supplied" do
      Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        [bibliography]
        == Normative references
      INPUT
      expect(File.read("test.err.html"))
        .not_to include("Normative references missing")
    end

    it "Normative references not missing in amendments" do
      Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: amendment

        text
      INPUT
      expect(File.read("test.err.html"))
        .not_to include("Normative references missing")
    end
  end

  context "Warns of missing terms & definitions" do
    it "Terms & definitions missing" do
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
        .to include("Terms & definitions missing")
    end

    it "Terms & definitions not missing if supplied" do
      Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        == Terms and definitions
        === Term 1
      INPUT
      expect(File.read("test.err.html"))
        .not_to include("Terms & definitions missing")
    end

    it "Terms & definitions not missing in amendment" do
      Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: amendment

        text
      INPUT
      expect(File.read("test.err.html"))
        .not_to include("Terms & definitions missing")
    end
  end

  it "warns that Scope contains subclauses" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Scope

      === Scope subclause
    INPUT
    expect(File.read("test.err.html"))
      .to include("Scope contains subclauses: should be succinct")
  end

  # can't test: our asciidoc template won't allow this to be generated
  # it "Style warning if foreword contains subclauses" do
  # expect { Asciidoctor.convert(<<~"INPUT", *OPTIONS) }
  #   .to output(%r{non-standard unit}).to_stderr
  #  #{VALIDATING_BLANK_HDR}
  #
  # INPUT
  # end

  # can't test: we strip out any such content from Normative references preemptively
  # it "Style warning if Normative References contains subclauses" do
  # expect { Asciidoctor.convert(<<~"INPUT", *OPTIONS) }
  #   .to output(%r{normative references contains subclauses}).to_stderr
  # #{VALIDATING_BLANK_HDR}
  #
  # [bibliography]
  #== Normative References
  #
  #=== Subsection
  # INPUT
  # end

  it "Style warning if two Symbols and Abbreviated Terms sections" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Terms and Abbreviations

      === Symbols and Abbreviated Terms

      == Symbols and Abbreviated Terms
    INPUT
    expect(File.read("test.err.html"))
      .to include("Only one Symbols and Abbreviated Terms section " \
                  "in the standard")
  end

  it "Style warning if Symbols and Abbreviated Terms contains " \
     "extraneous matter" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Symbols and Abbreviated Terms

      Paragraph
    INPUT
    expect(File.read("test.err.html"))
      .to include("Symbols and Abbreviated Terms can only contain " \
                  "a definition list")

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Symbols and Abbreviated Terms

      A:: B
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Symbols and Abbreviated Terms can only contain " \
                      "a definition list")
  end

  it "Warning if missing foreword" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Symbols and Abbreviated Terms

      Paragraph
    INPUT
    expect(File.read("test.err.html"))
      .to include("Initial section must be (content) Foreword")

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment

      == Symbols and Abbreviated Terms

      Paragraph
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Initial section must be (content) Foreword")
  end

  it "Warning if do not start with scope or introduction" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}
      Foreword

      == Symbols and Abbreviated Terms

      Paragraph
    INPUT
    expect(File.read("test.err.html"))
      .to include("Prefatory material must be followed by (clause) Scope")

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment

      Foreword

      == Symbols and Abbreviated Terms

      Paragraph
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Prefatory material must be followed by (clause) Scope")
  end

  it "Warning if introduction not followed by scope" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      .Foreword
      Foreword

      == Introduction

      == Symbols and Abbreviated Terms

      Paragraph
    INPUT
    expect(File.read("test.err.html"))
      .to include("Prefatory material must be followed by (clause) Scope")

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment

      .Foreword
      Foreword

      == Introduction

      == Symbols and Abbreviated Terms

      Paragraph
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Prefatory material must be followed by (clause) Scope")
  end

  it "Warning if normative references not followed by terms and definitions" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Symbols and Abbreviated Terms

      Paragraph
    INPUT
    expect(File.read("test.err.html"))
      .to include("Normative References must be followed by " \
                  "Terms and Definitions")

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Symbols and Abbreviated Terms

      Paragraph
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Normative References must be followed by " \
                      "Terms and Definitions")
  end

  it "Warning if there are no clauses in the document" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Symbols and Abbreviated Terms

    INPUT
    expect(File.read("test.err.html"))
      .to include("Document must contain at least one clause")

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Symbols and Abbreviated Terms

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Document must contain at least one clause")
  end

  it "Warning if scope occurs after Terms and Definitions" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Clause

      == Scope

    INPUT
    expect(File.read("test.err.html"))
      .to include("Scope must occur before Terms and Definitions")

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Clause

      == Scope

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Scope must occur before Terms and Definitions")
  end

  it "Warning if Symbols and Abbreviated Terms does not occur immediately " \
     "after Terms and Definitions" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Clause

      == Symbols and Abbreviated Terms

    INPUT
    expect(File.read("test.err.html"))
      .to include("Only annexes and references can follow clauses")

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment


      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Clause

      == Symbols and Abbreviated Terms

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Only annexes and references can follow clauses")
  end

  it "Warning if no normative references" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      .Foreword
      Foreword

      == Scope

      == Terms and Definitions

      == Clause

      [appendix]
      == Appendix A

      [appendix]
      == Appendix B

      [appendix]
      == Appendix C

    INPUT
    expect(File.read("test.err.html"))
      .to include("Document must include (references) Normative References")

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment

      .Foreword
      Foreword

      == Scope

      == Terms and Definitions

      == Clause

      [appendix]
      == Appendix A

      [appendix]
      == Appendix B

      [appendix]
      == Appendix C

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Document must include (references) Normative References")
  end

  it "Warning if there are two Terms sections" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Scope

      == Terms and definitions

      == A Clause

      [heading=terms and definitions]
      == Terms related to clinical psychology

    INPUT
    expect(File.read("test.err.html"))
      .to include("Only annexes and references can follow clauses")
  end

  it "No warning if there are two Terms sections in a Vocabulary document" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :docsubtype: vocabulary

      == Scope

      == Terms and definitions

      == A Clause

      [heading=terms and definitions]
      == Terms related to clinical psychology

      [heading=symbols and abbreviated terms]
      == Symbols related to clinical psychology

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Only annexes and references can follow clauses")
    expect(File.read("test.err.html"))
      .not_to include("Scope must occur before Terms and Definitions")
    expect(File.read("test.err.html"))
      .to include("Only annexes and references can follow terms and clauses")
  end

  it "No warning if there are two Symbols sections in a Vocabulary document" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :docsubtype: vocabulary

      == Scope

      == Terms and definitions

      == A Clause

      [heading=symbols and abbreviated terms]
      == Terms related to clinical psychology

      [heading=symbols and abbreviated terms]
      == Symbols related to clinical psychology

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Only one Symbols and Abbreviated Terms section " \
                      "in the standard")
  end

  it "Warn if single terms section in vocabulary document not named properly" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :docsubtype: vocabulary

      == Scope
      [heading=terms and definitions]
      == Terms and redefinitions

    INPUT
    expect(File.read("test.err.html"))
      .to include("Single terms clause in vocabulary document should have " \
                  "normal Terms and definitions heading")
    expect(File.read("test.err.html"))
      .not_to include("Multiple terms clauses in vocabulary document should " \
                      "have 'Terms related to' heading")
  end

  it "Warn if vocabulary document contains Symbols section outside annex" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :docsubtype: vocabulary

      == Scope

      == Terms and definitions

      == A Clause

      [heading=symbols and abbreviated terms]
      == Terms related to clinical psychology

    INPUT
    expect(File.read("test.err.html"))
      .to include("In vocabulary documents, Symbols and Abbreviated Terms are " \
                  "only permitted in annexes")
  end

  it "Warning if multiple terms section in vocabulary document not named " \
     "properly" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :docsubtype: vocabulary

      == Terms and definitions

      [heading=terms and definitions]
      == Terms related to fish

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Single terms clause in vocabulary document should have " \
                      "normal Terms and definitions heading")
    expect(File.read("test.err.html"))
      .to include("Multiple terms clauses in vocabulary document should " \
                  "have 'Terms related to' heading")
  end

  it "Warning if final section is not named Bibliography" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Clause

      [appendix]
      == Appendix A

      [appendix]
      == Appendix B

      [bibliography]
      == Bibliography

      [bibliography]
      == Appendix C

    INPUT
    expect(File.read("test.err.html"))
      .to include("There are sections after the final Bibliography")

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Clause

      [appendix]
      == Appendix A

      [appendix]
      == Appendix B

      [bibliography]
      == Bibliography

      [bibliography]
      == Appendix C

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("There are sections after the final Bibliography")
  end

  it "Warning if final section is not styled Bibliography" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Clause

      [appendix]
      == Appendix A

      [appendix]
      == Appendix B

      == Bibliography

    INPUT
    expect(File.read("test.err.html"))
      .to include("Section not marked up as [bibliography]")
  end

  it "Warning if final section is not styled Bibliography false" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: amendment

      .Foreword
      Foreword

      == Scope

      [bibliography]
      == Normative References

      == Terms and Definitions

      == Clause

      [appendix]
      == Appendix A

      [appendix]
      == Appendix B

      == Bibliography

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Section not marked up as [bibliography]")
  end

  it "Each first-level subclause must have a title" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}
      == Clause

      === {blank}
    INPUT
    expect(File.read("test.err.html"))
      .to include("each first-level subclause must have a title")
  end

  it "All subclauses must have a title, or none" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}
      == Clause

      === Subclause

      ==== {blank}

      ==== Subsubclause
    INPUT
    expect(File.read("test.err.html"))
      .to include("all subclauses must have a title, or none")
  end

  it "Warning if subclause is only child of its parent, or none" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}
      == Clause

      === Subclause

    INPUT
    expect(File.read("test.err.html")).to include("subclause is only child")
  end

  it "Warn if more than 7 levels of subclause" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      === Clause

      ==== Clause

      ===== Clause

      ====== Clause

      [level=6]
      ====== Clause

      [level=7]
      ====== Clause

      [level=8]
      ====== Clause

    INPUT
    expect(File.read("test.err.html"))
      .to include("Exceeds the maximum clause depth of 7")
  end

  it "Do not warn if not more than 7 levels of subclause" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause

      === Clause

      ==== Clause

      ===== Clause

      ====== Clause

      [level=6]
      ====== Clause

      [level=7]
      ====== Clause

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("exceeds the maximum clause depth of 7")
  end
end
