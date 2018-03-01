require "spec_helper"

RSpec.describe "warns when missing a title" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/Table should have title/).to_stderr }
  #{VALIDATING_BLANK_HDR}
  |===
  |A |B |C

  h|1 |2 |3
  |===
  INPUT
end


RSpec.describe "warn that introduction may contain requirement" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/Introduction may contain requirement/).to_stderr }
  #{VALIDATING_BLANK_HDR}
  == Introduction

  The widget is required not to be larger than 15 cm.
  INPUT
end

RSpec.describe "warn that foreword may contain recommendation" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/Foreword may contain recommendation/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  It is not recommended that widgets should be larger than 15 cm.

  == Clause
  INPUT
end

RSpec.describe "warn that foreword may contain permission" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/Foreword may contain permission/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  No widget is required to be larger than 15 cm.

  == Clause
  INPUT
end

RSpec.describe "warn that scope may contain recommendation" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/Scope may contain recommendation/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Scope
  It is not recommended that widgets should be larger than 15 cm.
  INPUT
end

RSpec.describe "warn that term example may contain recommendation" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/Term Example may contain recommendation/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Terms and Definitions

  === Term

  [example]
  It is not recommended that widgets should be larger than 15 cm.
  INPUT
end

RSpec.describe "warn that note may contain recommendation" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/Note may contain recommendation/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  NOTE: It is not recommended that widgets should be larger than 15 cm.
  INPUT
end

RSpec.describe "warn that footnote may contain recommendation" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/Footnote may contain recommendation/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  footnote:[It is not recommended that widgets should be larger than 15 cm.]
  INPUT
end

RSpec.describe "warn that term source is not in expected format" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/term reference not in expected format/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  [.source]
  I am a generic paragraph
  INPUT
end

RSpec.describe "warn that figure does not have title" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/Figure should have title/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  image::spec/examples/rice_images/rice_image1.png[]
  INPUT
end

RSpec.describe "warn that callouts do not match annotations" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/mismatch of callouts and annotations/).to_stderr }
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
end

RSpec.describe "term source is not a real reference" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/iso123 is not a real reference/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  [.source]
  <<iso123>>
  INPUT
end

RSpec.describe "Non-reference in bibliography" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(/no anchor on reference/).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Normative References
  * I am not a reference
  INPUT
end

RSpec.describe "Non-ISO reference in Normative References" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{non-ISO/IEC reference not expected as normative}).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Normative References
  * [[[XYZ,IESO 121]]] _Standard_
  INPUT
end

RSpec.describe "Scope contains subsections" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{Scope contains subsections: should be succint}).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Scope
  
  === Scope subsection
  INPUT
end


RSpec.describe "Table should have title" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{Table should have title}).to_stderr }
  #{VALIDATING_BLANK_HDR}     

  |===
  |a |b |c
  |===
  INPUT
end

RSpec.describe "Style warning if number not broken up in threes" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{number not broken up in threes}).to_stderr }
  #{VALIDATING_BLANK_HDR}     

  == Clause
  12121
  INPUT
end

RSpec.describe "No style warning if number not broken up in threes is ISO reference" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to_not output(%r{number not broken up in threes}).to_stderr }
  #{VALIDATING_BLANK_HDR}     

  == Clause
  ISO 12121
  INPUT
end

RSpec.describe "Style warning if decimal point" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{possible decimal point}).to_stderr }
  #{VALIDATING_BLANK_HDR}     

  == Clause
  8.1
  INPUT
end

RSpec.describe "Style warning if billion used" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{ambiguous number}).to_stderr }
  #{VALIDATING_BLANK_HDR}     

  == Clause
  "Billions" are a term of art.
  INPUT
end

RSpec.describe "Style warning if no space before percent sign" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{no space before percent sign}).to_stderr }
  #{VALIDATING_BLANK_HDR}     

  == Clause
  95%
  INPUT
end

RSpec.describe "Style warning if unbracketed tolerance before percent sign" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{unbracketed tolerance before percent sign}).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Clause
  95 ± 5 %
  INPUT
end

RSpec.describe "Style warning if dots in abbreviation" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{no dots in abbreviation}).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Clause
  r.p.m.
  INPUT
end

RSpec.describe "No Style warning if dots in abbreviation are e.g." do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to_not output(%r{no dots in abbreviation}).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Clause
  e.g. 5
  INPUT
end

RSpec.describe "Style warning if ppm used" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{language-specific abbreviation}).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Clause
  5 ppm
  INPUT
end

RSpec.describe "Style warning if space between number and degree" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{space between number and degrees/minutes/seconds}).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Clause
  5 °
  INPUT
end

RSpec.describe "Style warning if no space between number and SI unit" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{no space between number and SI unit}).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Clause
  A measurement of 5Bq was taken.
  INPUT
end

RSpec.describe "Style warning if mins used" do
  specify { expect { Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true) }.to output(%r{non-standard unit}).to_stderr }
  #{VALIDATING_BLANK_HDR}

  == Clause
  5 mins
  INPUT
end

