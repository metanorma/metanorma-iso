# frozen_string_literal: true

# P2-016 (#1728): excluded_styles keeps the REF-001 pollution styles from
# being mapped again, and no styleId the mapping emits may match an
# exclusion. Asserts on DocxStyleMapping#excluded?, the predicate
# StyleMappingValidator uses. Universal REF-001 styles must stay allowed.

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::DocxStyleMapping, "#excluded?" do
  subject(:mapping) { described_class.load_default }

  def emitted_style_ids
    (mapping.paragraph_styles.values + mapping.character_styles.values)
      .compact.map(&:to_s).uniq
  end

  it "no mapped paragraph or character style matches an excluded pattern" do
    leaks = emitted_style_ids.select { |id| mapping.excluded?(id) }
    expect(leaks).to be_empty,
                     "mapped styles in excluded_styles: #{leaks.join(', ')}"
  end

  {
    "8601 lowercase content style" => "note",
    "8601 lowercase family member" => "aubase",
    "8601 CamelCase extra" => "ListParagraph",
    "Word built-in table style" => "TableFormula",
    "Chinese Word numeric styleId" => "21103",
    "German locale auto-style" => "Code-einrck",
    "numeric collision suffix" => "Heading11",
    "character collision suffix" => "BaseTextChar",
    "OGC pipeline leak" => "OGCClause",
    "EndNote auto-style" => "EndNoteBibliography",
    "author one-off" => "Foreword",
  }.each do |category, style_id|
    it "excludes #{style_id} (#{category})" do
      expect(mapping.excluded?(style_id)).to be(true)
    end
  end

  it "keeps the stem span style allowed (StyleResolver emits it via SPAN_CLASS_TO_STYLE)" do
    expect(mapping.excluded?("stem")).to be(false)
  end

  it "keeps universal REF-001 styles allowed, including BodyTextindent1" do
    %w[BodyTextindent1 BodyTextChar FootnoteTextChar HeaderChar FooterChar
       TableNormal Heading1 Heading6 Notice].each do |style_id|
      expect(mapping.excluded?(style_id)).to be(false), style_id
    end
  end
end
