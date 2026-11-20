# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::Base do
  let(:t) { Metanorma::Iso::Sts::Transformer }
  let(:source) do
    t::SourceDocument.parse(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard"><title language="en" type="main">T</title>
          <docidentifier>ISO 1</docidentifier></bibdata>
        <sections/>
      </metanorma>
    XML
  end
  let(:context) { t::Context.new(source) }
  let(:base) { described_class.new(context) }

  it "keeps the context it was built with" do
    expect(base.context).to equal(context)
  end

  it "exposes the context's source and id generator to subclasses" do
    expect(base.send(:source)).to equal(source)
    expect(base.send(:id_generator)).to equal(context.id_generator)
  end

  {
    dispatcher: :BlockDispatcher,
    paragraph_transformer: :ParagraphTransformer,
    inline_transformer: :InlineTransformer,
    list_transformer: :ListTransformer,
    table_transformer: :TableTransformer,
    figure_transformer: :FigureTransformer,
    formula_transformer: :FormulaTransformer,
    note_transformer: :NoteTransformer,
    requirement_transformer: :RequirementTransformer,
    reference_transformer: :ReferenceTransformer,
    section_transformer: :SectionTransformer,
    term_transformer: :TermTransformer,
    dl_transformer: :DlTransformer,
    front_transformer: :FrontTransformer,
  }.each do |helper, klass|
    it "builds #{helper} as a #{klass} sharing the context, memoised" do
      first = base.send(helper)

      expect(first).to be_a(t.const_get(klass))
      expect(first.context).to equal(context)
      expect(base.send(helper)).to equal(first)
    end
  end

  it "keeps its collaborator helpers out of the public interface" do
    expect(base.public_methods(false)).to contain_exactly(:context)
    expect(base).not_to respond_to(:paragraph_transformer)
  end
end
