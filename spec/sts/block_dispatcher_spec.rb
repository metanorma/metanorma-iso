# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::BlockDispatcher do
  let(:context) { make_context }
  let(:dispatcher) { described_class.new(context) }

  it "dispatches a ParagraphBlock to the correct transformer" do
    source = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new
    source.text = ["Hello"]

    target = Sts::IsoSts::Sec.new
    target.instance_variable_set(:@__order_tracking__, true)

    result = dispatcher.dispatch(source, target)
    expect(result).to be true
  end

  it "returns false for unregistered node types" do
    target = Sts::IsoSts::Sec.new
    result = dispatcher.dispatch("a string", target)
    expect(result).to be false
  end

  it "allows registering new handlers" do
    custom_class = Class.new
    described_class.register(custom_class,
                             transformer_key: :paragraph_transformer,
                             transform_method: :transform,
                             target_setter: :p)

    entry = described_class.registry[custom_class]
    expect(entry).not_to be_nil
    expect(entry.target_setter).to eq(:p)
  end
end
