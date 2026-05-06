# frozen_string_literal: true

require "bundler/setup"
require "lutaml/model"
require "nokogiri"

require "sts"
require "metanorma/document"
require "metanorma/iso_document"

require "metanorma/iso/sts/transformer"

module TransformerTestHelpers
  def make_context(source_document = nil)
    Metanorma::Iso::Sts::Transformer::Context.new(source_document)
  end

  class MockModel
    def initialize(attrs = {})
      @attrs = attrs
    end

    def method_missing(name, *args)
      if name.to_s.end_with?("=") && args.length == 1
        @attrs[name.to_s.chomp("=").to_sym] = args[0]
      elsif @attrs.key?(name)
        @attrs[name]
      end
    end

    def respond_to_missing?(*)
      true
    end
  end

  def mock_bibdata(**overrides)
    MockModel.new({
      titles: [],
      docnumber: "99999",
      edition: nil,
      version: nil,
      date: [],
      contributor: [],
      copyright: [],
      language: ["en"],
      doc_identifier: [],
      ext: nil,
      status: nil,
    }.merge(overrides))
  end

  def mock_contributor(role_type: "publisher", abbr: "ISO")
    MockModel.new(
      role: MockModel.new(type: role_type),
      organization: MockModel.new(name: abbr, abbreviation: abbr),
    )
  end

  def mock_copyright(from: "2025", owner_name: "ISO")
    MockModel.new(
      from: from,
      owner: MockModel.new(
        organization: MockModel.new(name: owner_name, abbreviation: owner_name),
      ),
    )
  end

  def mock_ext(doctype: "international-standard", **overrides)
    MockModel.new({
      doctype: doctype,
      structuredidentifier: nil,
      editorial_group: nil,
      ics: nil,
    }.merge(overrides))
  end

  def mock_status(stage: "60")
    MockModel.new(stage: stage, stage_abbreviation: nil)
  end

  def mock_date(type: "released", on: "2025-01-01")
    MockModel.new(type: type, on: MockModel.new(content: on))
  end
end

RSpec.configure do |config|
  config.include TransformerTestHelpers
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
