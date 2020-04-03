require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ISO do

it "Warns of illegal doctype" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :doctype: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised document type"
end

it "Warns of illegal script" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :script: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised script"
end

it "Warns of illegal stage" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised stage"
end

it "Warns of illegal substage" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: 60
  :docsubstage: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised substage"
end

it "Warns of illegal iteration" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: 60
  :iteration: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised iteration"
end

it "Warns of illegal script" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :script: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised script"
end


it "warns that introduction may contain requirement" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  == Introduction

  The widget is required not to be larger than 15 cm.
  INPUT
    expect(File.read("test.err")).to include "Introduction may contain requirement"
end

it "warns that foreword may contain recommendation" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  It is not recommended that widgets should be larger than 15 cm.

  == Clause
  INPUT
    expect(File.read("test.err")).to include "Foreword may contain recommendation"
end

it "warns that foreword may contain permission" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  No widget is required to be larger than 15 cm.

  == Clause
  INPUT
    expect(File.read("test.err")).to include "Foreword may contain permission"
end

it "warns that scope may contain recommendation" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Scope
  It is not recommended that widgets should be larger than 15 cm.
  INPUT
    expect(File.read("test.err")).to include "Scope may contain recommendation"
end

it "warns that definition may contain requirement" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Terms and Definitions

  === Term1

  It is required that there is a definition.

  INPUT
    expect(File.read("test.err")).to include "Definition may contain requirement"
end

it "warns that term example may contain recommendation" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Terms and Definitions

  === Term

  [example]
  It is not recommended that widgets should be larger than 15 cm.
  INPUT
    expect(File.read("test.err")).to include "Example may contain recommendation"
end

it "warns that note may contain recommendation" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  NOTE: It is not recommended that widgets should be larger than 15 cm.
  INPUT
    expect(File.read("test.err")).to include "Note may contain recommendation"
end

it "warns that footnote may contain recommendation" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  footnote:[It is not recommended that widgets should be larger than 15 cm.]
  INPUT
    expect(File.read("test.err")).to include "Footnote may contain recommendation"
end

it "warns that term source is not in expected format" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  [.source]
  I am a generic paragraph
  INPUT
    expect(File.read("test.err")).to include "term reference not in expected format"
end

it "warns that figure does not have title" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  image::spec/examples/rice_images/rice_image1.png[]
  INPUT
    expect(File.read("test.err")).to include "Figure should have title"
end

it "warns that callouts do not match annotations" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{VALIDATING_BLANK_HDR}
      [source,ruby]
      --
      puts "Hello, world." <1>
      %w{a b c}.each do |x|
        puts x
      end
      --
      <1> This is one callout
      <2> This is another callout
      INPUT
    expect(File.read("test.err")).to include "mismatch of callouts and annotations"
end

it "warns that term source is not a real reference" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  [.source]
  <<iso123>>
  INPUT
    expect(File.read("test.err")).to include "iso123 does not have a corresponding anchor ID in the bibliography"
end

it "warns that undated reference has locality" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  
  == Scope
  <<iso123,clause=1>>

  [bibliography]
  == Normative References
  * [[[iso123,ISO 123]]] _Standard_
  INPUT
    expect(File.read("test.err")).to include "undated reference ISO 123 should not contain specific elements"
end

it "do not warn that undated reference which is a bibliographic reference has locality" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Scope
  <<iso123,clause=1>>

  [bibliography]
  == Bibliography
  * [[[iso123,1]]] _Standard_
  INPUT
    expect(File.read("test.err")).not_to include "undated reference [1] should not contain specific elements"
end

it "do not warn that undated IEV reference has locality" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Scope
  <<iev,clause=1>>

  [bibliography]
  == Normative References
  * [[[iev,IEV]]] _Standard_
  INPUT
    expect(File.read("test.err")).not_to include "undated reference IEV should not contain specific elements"
end

it "do not warn that in print has locality" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Scope
  <<iev,clause=1>>

  [bibliography]
  == Normative References
  * [[[iev,ISO 123:--]]] _Standard_
  INPUT
    expect(File.read("test.err")).not_to include "undated reference ISO 123 should not contain specific elements"
end

it "warns of Non-reference in bibliography" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Normative References
  * I am not a reference
  INPUT
    expect(File.read("test.err")).to include "no anchor on reference"
end

it "warns of Non-ISO reference in Normative References" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  [bibliography]
  == Normative References
  * [[[XYZ,IESO 121]]] _Standard_
  INPUT
    expect(File.read("test.err")).to include "non-ISO/IEC reference not expected as normative"
end

it "warns that Scope contains subclauses" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Scope
  
  === Scope subclause
  INPUT
    expect(File.read("test.err")).to include "Scope contains subclauses: should be succinct"
end


it "warns that Table should have title" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}     

  |===
  |a |b |c
  |===
  INPUT
    expect(File.read("test.err")).to include "Table should have title"
end

it "gives Style warning if number not broken up in threes" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}     

  == Clause
  12121
  INPUT
    expect(File.read("test.err")).to include "number not broken up in threes"
end

it "gives No style warning if number not broken up in threes is ISO reference" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}     

  == Clause
  ISO 12121
  INPUT
    expect(File.read("test.err")).not_to include "number not broken up in threes"
end

it "Style warning if decimal point" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}     

  == Clause
  8.1
  INPUT
    expect(File.read("test.err")).to include "possible decimal point"
end

it "Style warning if billion used" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}     

  == Clause
  "Billions" are a term of art.
  INPUT
    expect(File.read("test.err")).to include "ambiguous number"
end

it "Style warning if no space before percent sign" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}     

  == Clause
  95%
  INPUT
    expect(File.read("test.err")).to include "no space before percent sign"
end

it "Style warning if unbracketed tolerance before percent sign" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Clause
  95 ± 5 %
  INPUT
    expect(File.read("test.err")).to include "unbracketed tolerance before percent sign"
end

it "Style warning if dots in abbreviation" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Clause
  r.p.m.
  INPUT
    expect(File.read("test.err")).to include "no dots in abbreviation"
end

it "No Style warning if dots in abbreviation are e.g." do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Clause
  e.g. 5
  INPUT
    expect(File.read("test.err")).not_to include "no dots in abbreviation"
end

it "Style warning if ppm used" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Clause
  5 ppm
  INPUT
    expect(File.read("test.err")).to include "language-specific abbreviation"
end

it "Style warning if space between number and degree" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Clause
  5 °
  INPUT
    expect(File.read("test.err")).to include "space between number and degrees/minutes/seconds"
end

it "Style warning if no space between number and SI unit" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Clause
  A measurement of 5Bq was taken.
  INPUT
    expect(File.read("test.err")).to include "no space between number and SI unit"
end

it "Style warning if mins used" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Clause
  5 mins
  INPUT
    expect(File.read("test.err")).to include "non-standard unit"
end

# can't test: our asciidoc template won't allow this to be generated
# it "Style warning if foreword contains subclauses" do
  # expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{non-standard unit}).to_stderr
  #  #{VALIDATING_BLANK_HDR}
# 
  # INPUT
# end

# can't test: we strip out any such content from Normative references preemptively
#it "Style warning if Normative References contains subclauses" do
  #expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{normative references contains subclauses}).to_stderr
  ##{VALIDATING_BLANK_HDR}
#
  #[bibliography]
  #== Normative References
  #
  #=== Subsection
  #INPUT
#end

it "Style warning if two Symbols and Abbreviated Terms sections" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Terms and Abbreviations

  === Symbols and Abbreviated Terms

  == Symbols and Abbreviated Terms
  INPUT
    expect(File.read("test.err")).to include "Only one Symbols and Abbreviated Terms section in the standard"
end

it "Style warning if Symbols and Abbreviated Terms contains extraneous matter" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
    expect(File.read("test.err")).to include "Symbols and Abbreviated Terms can only contain a definition list"
end

it "Warning if do not start with scope or introduction" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
    expect(File.read("test.err")).to include "Prefatory material must be followed by (clause) Scope"
end

it "Warning if introduction not followed by scope" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  .Foreword 
  Foreword

  == Introduction

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
    expect(File.read("test.err")).to include "Prefatory material must be followed by (clause) Scope"
end

it "Warning if normative references not followed by terms and definitions" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  .Foreword 
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Symbols and Abbreviated Terms

  Paragraph
  INPUT
    expect(File.read("test.err")).to include "Normative References must be followed by Terms and Definitions"
end

it "Warning if there are no clauses in the document" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  .Foreword 
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Symbols and Abbreviated Terms

  INPUT
    expect(File.read("test.err")).to include "Document must contain clause after Terms and Definitions"
end

it "Warning if scope occurs after Terms and Definitions" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  .Foreword
  Foreword

  == Scope

  [bibliography]
  == Normative References

  == Terms and Definitions

  == Scope

  INPUT
    expect(File.read("test.err")).to include "Scope must occur before Terms and Definitions"
end

it "Warning if scope occurs after Terms and Definitions" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
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
    expect(File.read("test.err")).to include "Scope must occur before Terms and Definitions"
end

it "Warning if Symbols and Abbreviated Terms does not occur immediately after Terms and Definitions" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
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
    expect(File.read("test.err")).to include "Only annexes and references can follow clauses"
end

it "Warning if no normative references" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
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
    expect(File.read("test.err")).to include "Document must include (references) Normative References"
end

it "Warning if final section is not named Bibliography" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
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
    expect(File.read("test.err")).to include "There are sections after the final Bibliography"
end

it "Warning if final section is not styled Bibliography" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
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
    expect(File.read("test.err")).to include "Section not marked up as [bibliography]"
end

it "Warning if English title intro and no French title intro" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :title-intro-en: Title
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "No French Title Intro"
end

it "Warning if French title intro and no English title intro" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :title-intro-fr: Title
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "No English Title Intro"
end


it "Warning if English title and no French intro" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :title-main-en: Title
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "No French Title"
end

it "Warning if French title and no English title" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :title-main-fr: Title
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "No English Title"
end

it "Warning if English title part and no French title part" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :title-part-en: Title
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "No French Title Part"
end

it "Warning if French title part and no English title part" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :title-part-fr: Title
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "No English Title Part"
end

it "Warning if non-IEC document with subpart" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :docnumber: 10
  :partnumber: 1-1
  :publisher: ISO
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "Subpart defined on non-IEC document"
end

it "No warning if joint IEC/non-IEC document with subpart" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :docnumber: 10
  :partnumber: 1-1
  :publisher: ISO,IEC
  :no-isobib:

  INPUT
    expect(File.read("test.err")).not_to include "Subpart defined on non-IEC document"
end

it "Warning if main title contains document type" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :title-main-en: A Technical Specification on Widgets
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "Main Title may name document type"
end

it "Warning if intro title contains document type" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :title-intro-en: A Technical Specification on Widgets
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "Title Intro may name document type"
end

it "Each first-level subclause must have a title" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  == Clause

  === {blank}
  INPUT
    expect(File.read("test.err")).to include "each first-level subclause must have a title"
end

it "All subclauses must have a title, or none" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  == Clause

  === Subclause

  ==== {blank}

  ==== Subsubclause
  INPUT
    expect(File.read("test.err")).to include "all subclauses must have a title, or none"
end

it "Warning if subclause is only child of its parent, or none" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  == Clause

  === Subclause

  INPUT
    expect(File.read("test.err")).to include "subclause is only child"
end

it "Warning if invalid technical committee type" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :technical-committee-type: X
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "invalid technical committee type"
end

it "Warning if invalid subcommittee type" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :subcommittee-type: X
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "invalid subcommittee type"
end

it "Warning if invalid subcommittee type" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :subcommittee-type: X
  :no-isobib:

  INPUT
    expect(File.read("test.err")).to include "invalid subcommittee type"
end

it "Warning if 'see' crossreference points to normative section" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  [[terms]]
  == Terms and Definitions

  == Clause
  See <<terms>>
  INPUT
    expect(File.read("test.err")).to include "'see terms' is pointing to a normative section"
end

it "Warning if 'see' reference points to normative reference" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  [bibliography]
  == Normative References
  * [[[terms,ISO 1]]] _References_

  == Clause
  See <<terms>>
  INPUT
    expect(File.read("test.err")).to include "is pointing to a normative reference"
end

it "Warning if term definition starts with article" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  == Terms and Definitions
  
  === Term

  The definition of a term is a part of the specialized vocabulary of a particular field
  INPUT
    expect(File.read("test.err")).to include "term definition starts with article"
end

it "Warning if term definition ends with period" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  == Terms and Definitions
  
  === Term

  Part of the specialized vocabulary of a particular field.
  INPUT
    expect(File.read("test.err")).to include "term definition ends with period"
end

it "validates document against ISO XML schema" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}

  [align=mid-air]
  Para
  INPUT
    expect(File.read("test.err")).to include 'value of attribute "align" is invalid; must be equal to'
end

it "Warn if more than 7 levels of subclause" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :language: fr

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
    expect(File.read("test.err")).to include "Exceeds the maximum clause depth of 7"
end

it "Do not warn if not more than 7 levels of subclause" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :language: fr

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
    expect(File.read("test.err")).not_to include "exceeds the maximum clause depth of 7"
end

it "Warn if term citation in Terms & Definitions not preceded with italicised term" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  == Terms and Definitions

  [[term]]
  === Term

  The definition of a term (<<term>>) is a part of the specialized vocabulary of a particular field
  INPUT
    expect(File.read("test.err")).to include "term citation not preceded with italicised term"
end

it "Warn if an undated reference has no associated footnote" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  #{VALIDATING_BLANK_HDR}
  
  [bibliography]
  == Bibliography
  * [[[ISO8,ISO 8:--]]], _Title_
  INPUT
    expect(File.read("test.err")).to include "Reference ISO8 does not have an associated footnote indicating unpublished status"
end


end
