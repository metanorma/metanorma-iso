# frozen_string_literal: true

require "uniword/validation/rules"

RSpec.shared_examples "a valid DOCX" do |path|
  it "passes Uniword validation rules without errors" do
    ctx = Uniword::Validation::Rules::DocumentContext.new(path)
    errors = Uniword::Validation::Rules::Registry.all.flat_map do |rule|
      rule.applicable?(ctx) ? rule.check(ctx) : []
    end.select { |i| i.severity == "error" }

    ctx.close

    expect(errors).to be_empty,
      "DOCX validation errors:\n#{errors.map { |e| "  #{e.code}: #{e.message}" }.join("\n")}"
  end
end
