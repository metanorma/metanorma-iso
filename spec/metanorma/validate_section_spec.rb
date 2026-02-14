require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Iso, type: :validation do
  before do
    FileUtils.rm_rf("test.err.html")
  end

  context "Warns of missing scope" do
    let(:missing_scope_errors) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        text
      INPUT
    end

    let(:with_scope_errors) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        == Scope
      INPUT
    end

    let(:amendment_errors) do
      FileUtils.rm_f "test.err.html"
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: amendment

        text
      INPUT
    end

    it "Scope clause missing" do
      expect(missing_scope_errors).to include("Scope clause missing")
    end

    it "Scope clause not missing if supplied" do
      expect(with_scope_errors).not_to include("Scope clause missing")
    end

    it "Scope clause not missing in amendments" do
      expect(amendment_errors).not_to include("Scope clause missing")
    end
  end

  context "Warns of missing normative references" do
    let(:missing_normrefs_errors) do
      FileUtils.rm_f "test.err.html"
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        text
      INPUT
    end

    let(:with_normrefs_errors) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        [bibliography]
        == Normative references
      INPUT
    end

    let(:amendment_normrefs_errors) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: amendment

        text
      INPUT
    end

    it "Normative references missing" do
      expect(missing_normrefs_errors).to include("Normative references missing")
    end

    it "Normative references not missing if supplied" do
      expect(with_normrefs_errors).not_to include("Normative references missing")
    end

    it "Normative references not missing in amendments" do
      expect(amendment_normrefs_errors).not_to include("Normative references missing")
    end
  end

  context "Warns of missing terms & definitions" do
    let(:missing_terms_errors) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        text
      INPUT
    end

    let(:with_terms_errors) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: pizza

        == Terms and definitions
        === Term 1
      INPUT
    end

    let(:amendment_terms_errors) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: amendment

        text
      INPUT
    end

    it "Terms & definitions missing" do
      expect(missing_terms_errors).to include("Terms & definitions missing")
    end

    it "Terms & definitions not missing if supplied" do
      expect(with_terms_errors).not_to include("Terms & definitions missing")
    end

    it "Terms & definitions not missing in amendment" do
      expect(amendment_terms_errors).not_to include("Terms & definitions missing")
    end
  end

  it "warns that Scope contains subclauses" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Scope

      === Scope subclause
    INPUT
    expect(errors).to include("Scope contains subclauses: should be succinct")
  end

  it "Style warning if two Symbols and Abbreviated Terms sections" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Terms and Abbreviations

      === Symbols and Abbreviated Terms

      == Symbols and Abbreviated Terms
    INPUT
    expect(errors).to include("Only one Symbols and Abbreviated Terms section in the standard")
  end

  context "Symbols and Abbreviated Terms validation" do
    let(:with_paragraph_errors) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Symbols and Abbreviated Terms

        Paragraph
      INPUT
    end

    let(:with_deflist_errors) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Symbols and Abbreviated Terms

        A:: B
      INPUT
    end

    it "Style warning if Symbols and Abbreviated Terms contains extraneous matter" do
      expect(with_paragraph_errors).to include("Symbols and Abbreviated Terms can only contain a definition list")
    end

    it "No warning if contains definition list" do
      expect(with_deflist_errors).not_to include("Symbols and Abbreviated Terms can only contain a definition list")
    end
  end

  context "Foreword validation" do
    let(:missing_foreword_errors) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        == Symbols and Abbreviated Terms

        Paragraph
      INPUT
    end

    let(:amendment_foreword_errors) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: amendment

        == Symbols and Abbreviated Terms

        Paragraph
      INPUT
    end

    it "Warning if missing foreword" do
      expect(missing_foreword_errors).to include("Initial section must be (content) Foreword")
    end

    it "No warning in amendments" do
      expect(amendment_foreword_errors).not_to include("Initial section must be (content) Foreword")
    end
  end

  context "Scope position validation" do
    let(:missing_scope_after_foreword_errors) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}
        Foreword

        == Symbols and Abbreviated Terms

        Paragraph
      INPUT
    end

    let(:amendment_scope_errors) do
      convert_and_capture_errors(<<~INPUT)
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
    end

    it "Warning if do not start with scope or introduction" do
      expect(missing_scope_after_foreword_errors).to include("Prefatory material must be followed by (clause) Scope")
    end

    it "No warning in amendments" do
      expect(amendment_scope_errors).not_to include("Prefatory material must be followed by (clause) Scope")
    end
  end

  context "Introduction followed by scope" do
    let(:intro_not_followed_by_scope_errors) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        .Foreword
        Foreword

        == Introduction

        == Symbols and Abbreviated Terms

        Paragraph
      INPUT
    end

    let(:amendment_intro_errors) do
      convert_and_capture_errors(<<~INPUT)
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
    end

    it "Warning if introduction not followed by scope" do
      expect(intro_not_followed_by_scope_errors).to include("Prefatory material must be followed by (clause) Scope")
    end

    it "No warning in amendments" do
      expect(amendment_intro_errors).not_to include("Prefatory material must be followed by (clause) Scope")
    end
  end

  context "Normative references followed by terms" do
    let(:normrefs_not_followed_by_terms_errors) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        .Foreword
        Foreword

        == Scope

        [bibliography]
        == Normative References

        == Symbols and Abbreviated Terms

        Paragraph
      INPUT
    end

    let(:amendment_normrefs_errors) do
      convert_and_capture_errors(<<~INPUT)
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
    end

    it "Warning if normative references not followed by terms and definitions" do
      expect(normrefs_not_followed_by_terms_errors).to include("Normative References must be followed by Terms and Definitions")
    end

    it "No warning in amendments" do
      expect(amendment_normrefs_errors).not_to include("Normative References must be followed by Terms and Definitions")
    end
  end

  context "Document must contain clauses" do
    let(:no_clauses_errors) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        .Foreword
        Foreword

        == Scope

        [bibliography]
        == Normative References

        == Terms and Definitions

        == Symbols and Abbreviated Terms

      INPUT
    end

    let(:amendment_no_clauses_errors) do
      convert_and_capture_errors(<<~INPUT)
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
    end

    it "Warning if there are no clauses in the document" do
      expect(no_clauses_errors).to include("Document must contain at least one clause")
    end

    it "No warning in amendments" do
      expect(amendment_no_clauses_errors).not_to include("Document must contain at least one clause")
    end
  end

  context "Scope position after Terms" do
    let(:scope_after_terms_with_initial_scope) do
      convert_and_capture_errors(<<~"INPUT")
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
    end

    let(:scope_after_terms_without_initial) do
      convert_and_capture_errors(<<~"INPUT")
        #{VALIDATING_BLANK_HDR}

        .Foreword
        Foreword

        [bibliography]
        == Normative References

        == Terms and Definitions

        == Clause

        == Scope

      INPUT
    end

    let(:amendment_scope_after_terms) do
      convert_and_capture_errors(<<~INPUT)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :doctype: amendment

        .Foreword
        Foreword

        [bibliography]
        == Normative References

        == Terms and Definitions

        == Clause

        == Scope

      INPUT
    end

    it "Warning if scope occurs after Terms and Definitions" do
      expect(scope_after_terms_with_initial_scope).not_to include("Scope must not occur after Terms and Definitions")
      expect(scope_after_terms_without_initial).to include("Scope must not occur after Terms and Definitions")
    end

    it "No warning in amendments" do
      expect(amendment_scope_after_terms).not_to include("Scope must not occur after Terms and Definitions")
    end
  end

  it "Warning if Symbols and Abbreviated Terms does not occur immediately after Terms and Definitions" do
    errors_standard = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors_standard).to include("Only annexes and references can follow clauses")

    errors_amendment = convert_and_capture_errors(<<~INPUT)
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
    expect(errors_amendment).not_to include("Only annexes and references can follow clauses")
  end

  context "Normative references presence" do
    let(:no_normrefs_errors) do
      convert_and_capture_errors(<<~"INPUT")
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
    end

    let(:amendment_no_normrefs) do
      convert_and_capture_errors(<<~INPUT)
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
    end

    it "Warning if no normative references" do
      expect(no_normrefs_errors).to include("Document must include (references) Normative References")
    end

    it "No warning in amendments" do
      expect(amendment_no_normrefs).not_to include("Document must include (references) Normative References")
    end
  end

  it "Warning if there are two Terms sections" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}

      == Scope

      == Terms and definitions

      == A Clause

      [heading=terms and definitions]
      == Terms related to clinical psychology

    INPUT
    expect(errors).to include("Only annexes and references can follow clauses")
  end

  it "No warning if there are two Terms sections in a Vocabulary document" do
    errors = convert_and_capture_errors(<<~INPUT)
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
    expect(errors).not_to include("Only annexes and references can follow clauses")
    expect(errors).not_to include("Scope must not occur after Terms and Definitions")
    expect(errors).to include("Only annexes and references can follow terms and clauses")
  end

  it "No warning if there are two Symbols sections in a Vocabulary document" do
    errors = convert_and_capture_errors(<<~INPUT)
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
    expect(errors).not_to include("Only one Symbols and Abbreviated Terms section in the standard")
  end

  it "Warn if single terms section in vocabulary document not named properly" do
    errors = convert_and_capture_errors(<<~INPUT)
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
    expect(errors).to include("Single terms clause in vocabulary document should have normal Terms and definitions heading")
    expect(errors).not_to include("Multiple terms clauses in vocabulary document should have 'Terms related to' heading")
  end

  it "Warn if vocabulary document contains Symbols section outside annex" do
    errors = convert_and_capture_errors(<<~INPUT)
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
    expect(errors).to include("In vocabulary documents, Symbols and Abbreviated Terms are only permitted in annexes")
  end

  it "Warning if multiple terms section in vocabulary document not named properly" do
    errors = convert_and_capture_errors(<<~INPUT)
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
    expect(errors).not_to include("Single terms clause in vocabulary document should have normal Terms and definitions heading")
    expect(errors).to include("Multiple terms clauses in vocabulary document should have 'Terms related to' heading")
  end

  context "Bibliography position" do
    let(:sections_after_bibliography) do
      convert_and_capture_errors(<<~"INPUT")
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
    end

    let(:amendment_bibliography) do
      convert_and_capture_errors(<<~INPUT)
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
    end

    it "Warning if final section is not named Bibliography" do
      expect(sections_after_bibliography).to include("There are sections after the final Bibliography")
    end

    it "No warning in amendments" do
      expect(amendment_bibliography).not_to include("There are sections after the final Bibliography")
    end
  end

  context "Bibliography markup" do
    let(:bibliography_not_styled) do
      convert_and_capture_errors(<<~"INPUT")
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
    end

    let(:amendment_bibliography_markup) do
      convert_and_capture_errors(<<~INPUT)
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
    end

    it "Warning if final section is not styled Bibliography" do
      expect(bibliography_not_styled).to include("Section not marked up as [bibliography]")
    end

    it "Warning if final section is not styled Bibliography false" do
      expect(amendment_bibliography_markup).not_to include("Section not marked up as [bibliography]")
    end
  end

  it "Each first-level subclause must have a title" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}
      == Clause

      === {blank}
    INPUT
    expect(errors).to include("each first-level subclause must have a title")
  end

  it "All subclauses must have a title, or none" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}
      == Clause

      === Subclause

      ==== {blank}

      ==== Subsubclause
    INPUT
    expect(errors).to include("all subclauses must have a title, or none")
  end

  it "Warning if subclause is only child of its parent, or none" do
    errors = convert_and_capture_errors(<<~"INPUT")
      #{VALIDATING_BLANK_HDR}
      == Clause

      === Subclause

    INPUT
    expect(errors).to include("subclause is only child")
  end

  it "Warn if more than 7 levels of subclause" do
    errors = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors).to include("Exceeds the maximum clause depth of 7")
  end

  it "Do not warn if not more than 7 levels of subclause" do
    errors = convert_and_capture_errors(<<~"INPUT")
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
    expect(errors).not_to include("exceeds the maximum clause depth of 7")
  end
end
