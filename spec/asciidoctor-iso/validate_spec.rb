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
