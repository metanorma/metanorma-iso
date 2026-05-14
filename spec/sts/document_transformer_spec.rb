# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::DocumentTransformer do
  let(:context) { make_context }
  let(:transformer) { described_class.new(context) }

  describe "#apply_nbsp_to_text" do
    it "applies NBSP only to text content between tags" do
      xml = "<p>See ISO 8601 for details</p>"
      result = transformer.send(:apply_nbsp_to_text, xml)
      expect(result).to include("ISO 8601")
    end

    it "does not modify attribute values" do
      xml = '<p id="ISO 8601">Text</p>'
      result = transformer.send(:apply_nbsp_to_text, xml)
      expect(result).to include('id="ISO 8601"')
    end
  end
end
