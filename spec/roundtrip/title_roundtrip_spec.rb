# frozen_string_literal: true

require "bundler/setup"
require "rspec/matchers"
require "metanorma/iso/document"
require_relative "../support/roundtrip_helper"
require_relative "../support/shared_roundtrip_examples"

RSpec.describe "Title round-trip" do
  let(:xml) { File.read("spec/fixtures/iso/is/document-en.xml") }
  let(:doc) { Metanorma::Iso::Document::Root.from_xml(xml) }
  let(:bibdata) { doc.bibdata }

  it "parses title items" do
    expect(bibdata.titles.items).not_to be_empty
  end

  it "groups titles per language" do
    expect(bibdata.titles.per_language).not_to be_empty
  end

  it "finds the English title" do
    expect(bibdata.titles.for_language("en")).not_to be_nil
  end
end
