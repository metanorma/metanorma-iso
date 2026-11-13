# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Iso::Document::Metadata::TitleCollection do
  it "returns nil for a missing language instead of raising" do
    collection = described_class.new
    expect(collection.for_language("en")).to be_nil
  end
end
