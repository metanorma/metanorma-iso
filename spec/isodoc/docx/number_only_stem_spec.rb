# frozen_string_literal: true

require "spec_helper"

RSpec.describe "number-only inline stems" do
  # 1.17.0 parity: a stem consisting of a bare number renders as plain
  # text in the Word output, not as an OMML equation object and not
  # dropped (metanorma-iso#1764).
  it "renders a number-only stem as a text run" do
    expect(number_only_stem_text_for("<math><mn>0</mn></math>")).to eq("0")
    expect(number_only_stem_text_for("<math><mn>12</mn></math>")).to eq("12")
  end

  it "keeps structured stems as equations" do
    expect(number_only_stem_text_for(
      "<math><msup><mn>2</mn><mn>0</mn></msup></math>"
    )).to be_nil
    expect(number_only_stem_text_for(
      "<math><mi>x</mi></math>"
    )).to be_nil
    expect(number_only_stem_text_for(
      "<math><mn>0</mn><mo>+</mo><mn>1</mn></math>"
    )).to be_nil
  end

  private

  def number_only_stem_text_for(mathml)
    stub_stem = Object.new
    stub_stem.define_singleton_method(:class) { Struct.new(:attributes).new(Struct.new(:key?).new(false)) }
    walk = docx_walk_instance
    walk.number_only_stem_text(stub_mathml_stem(mathml))
  end
end
