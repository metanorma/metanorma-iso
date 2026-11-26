# frozen_string_literal: true

require "metanorma/iso/document"

module Metanorma
  module Iso
    module Sts
      # The ISO publisher profile for the shared STS engine
      # (metanorma-document 0.5.15, Metanorma::Document::Sts) —
      # metanorma-iso#1760 / metanorma-document#165. Supplies the ISO
      # document-model reader and the ISO validator; class_overrides
      # activate ISO-specific wiring as the delegation waves proceed.
      class Profile
        def self.instance
          @instance ||= Metanorma::Document::Sts::Profile.new(
            name: :iso,
            org_abbrev: "ISO",
            reader_class: Metanorma::Iso::Document::Root,
            validator_class: Metanorma::Iso::Sts::Validator,
            identity: Metanorma::Document::Sts::Profile::Identity.new(
              publisher_name: "ISO",
              publisher_address: "",
              version_string: "",
            ),
            class_overrides: overrides,
          ).freeze.tap { |p| Metanorma::Document::Sts::Profiles.register(p) }
        end

        # Built lazily: the ISO subclasses load via autoload after this
        # file, so the constant references resolve on first use.
        def self.overrides
          {
          Metanorma::Document::Sts::HtmlRenderer::Ruby => Metanorma::Iso::Sts::HtmlRenderer::Ruby,
          Metanorma::Document::Sts::ParityValidator::Normaliser => Metanorma::Iso::Sts::ParityValidator::Normaliser,
          Metanorma::Document::Sts::ParityValidator::Report => Metanorma::Iso::Sts::ParityValidator::Report,
          Metanorma::Document::Sts::Transformer::BackTransformer => Metanorma::Iso::Sts::Transformer::BackTransformer,
          Metanorma::Document::Sts::Transformer::Base => Metanorma::Iso::Sts::Transformer::Base,
          Metanorma::Document::Sts::Transformer::BlockDispatcher => Metanorma::Iso::Sts::Transformer::BlockDispatcher,
          Metanorma::Document::Sts::Transformer::BodyTransformer => Metanorma::Iso::Sts::Transformer::BodyTransformer,
          Metanorma::Document::Sts::Transformer::Context => Metanorma::Iso::Sts::Transformer::Context,
          Metanorma::Document::Sts::Transformer::DlTransformer => Metanorma::Iso::Sts::Transformer::DlTransformer,
          Metanorma::Document::Sts::Transformer::DocumentTransformer => Metanorma::Iso::Sts::Transformer::DocumentTransformer,
          Metanorma::Document::Sts::Transformer::FigureTransformer => Metanorma::Iso::Sts::Transformer::FigureTransformer,
          Metanorma::Document::Sts::Transformer::FootnoteCollector => Metanorma::Iso::Sts::Transformer::FootnoteCollector,
          Metanorma::Document::Sts::Transformer::FormulaTransformer => Metanorma::Iso::Sts::Transformer::FormulaTransformer,
          Metanorma::Document::Sts::Transformer::FrontTransformer => Metanorma::Iso::Sts::Transformer::FrontTransformer,
          Metanorma::Document::Sts::Transformer::IdGenerator => Metanorma::Iso::Sts::Transformer::IdGenerator,
          Metanorma::Document::Sts::Transformer::InlineTransformer => Metanorma::Iso::Sts::Transformer::InlineTransformer,
          Metanorma::Document::Sts::Transformer::ListTransformer => Metanorma::Iso::Sts::Transformer::ListTransformer,
          Metanorma::Document::Sts::Transformer::NoteTransformer => Metanorma::Iso::Sts::Transformer::NoteTransformer,
          Metanorma::Document::Sts::Transformer::ParagraphTransformer => Metanorma::Iso::Sts::Transformer::ParagraphTransformer,
          Metanorma::Document::Sts::Transformer::ProvisionIndex => Metanorma::Iso::Sts::Transformer::ProvisionIndex,
          Metanorma::Document::Sts::Transformer::QuoteTransformer => Metanorma::Iso::Sts::Transformer::QuoteTransformer,
          Metanorma::Document::Sts::Transformer::ReferenceTransformer => Metanorma::Iso::Sts::Transformer::ReferenceTransformer,
          Metanorma::Document::Sts::Transformer::RenderedTextExtractor => Metanorma::Iso::Sts::Transformer::RenderedTextExtractor,
          Metanorma::Document::Sts::Transformer::RequirementTransformer => Metanorma::Iso::Sts::Transformer::RequirementTransformer,
          Metanorma::Document::Sts::Transformer::SectionTransformer => Metanorma::Iso::Sts::Transformer::SectionTransformer,
          Metanorma::Document::Sts::Transformer::Standard => Metanorma::Iso::Sts::Transformer::Standard,
          Metanorma::Document::Sts::Transformer::TableTransformer => Metanorma::Iso::Sts::Transformer::TableTransformer,
          Metanorma::Document::Sts::Transformer::TermTransformer => Metanorma::Iso::Sts::Transformer::TermTransformer,
          Metanorma::Document::Sts::ValidationReport => Metanorma::Iso::Sts::ValidationReport,
          Metanorma::Document::Sts::Validator => Metanorma::Iso::Sts::Validator,
          }
        end
      end
    end
  end
end
