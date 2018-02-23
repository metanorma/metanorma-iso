require 'rspec/match_fuzzy'

RSpec.describe Asciidoctor::ISO do
  it "has a version number" do
    expect(Html2Doc::VERSION).not_to be nil
  end

  it "processes a blank document" do
    Html2Doc.process(BLANK_HTML, "test", nil, nil, nil, nil)
    expect(guid_clean(File.read("test.doc", encoding: "utf-8"))).
      to match_fuzzy(<<~OUTPUT)
    #{WORD_HDR}
    #{DEFAULT_STYLESHEET}
    #{WORD_BODY}
    #{WORD_FTR}
    OUTPUT
  end
end
