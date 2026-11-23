# frozen_string_literal: true

require "lutaml/model"
require_relative "document/semx_element"

module Metanorma
  module Iso
    # ISO's lutaml-model register: wires Standoc section types to their
    # ISO counterparts for XML parsing. Formerly
    # Metanorma::Registers::Setup.setup_iso_register in metanorma-
    # document; the substitution data lives with the classes it names.
    module Registers
      module_function

      def setup
        sd = Metanorma::Standoc::Document
        iso = Metanorma::Iso::Document
        reg = Lutaml::Model::Register.new(:iso_document)
        Lutaml::Model::GlobalRegister.register(reg)

        reg.register_global_type_substitution(
          from_type: Metanorma::Document::Components::Inline::SemxElement,
          to_type: iso::SemxElement,
        )
        reg.register_global_type_substitution(
          from_type: Metanorma::Document::Components::Blocks::NoteBlock,
          to_type: iso::Blocks::NoteBlock,
        )
        reg.register_global_type_substitution(
          from_type: Metanorma::Document::Components::Lists::DdElement,
          to_type: iso::DdElement,
        )
        reg.register_global_type_substitution(
          from_type: Metanorma::Document::Components::Paragraphs::ParagraphBlock,
          to_type: iso::IsoParagraphBlock,
        )
        reg.register_global_type_substitution(
          from_type: sd::Sections::ClauseSection,
          to_type: iso::Sections::IsoClauseSection,
        )
        reg.register_global_type_substitution(
          from_type: sd::Sections::AnnexSection,
          to_type: iso::Sections::IsoAnnexSection,
        )
        reg.register_global_type_substitution(
          from_type: sd::Sections::Sections,
          to_type: iso::Sections::IsoSections,
        )
        reg.register_global_type_substitution(
          from_type: sd::Sections::Preface,
          to_type: iso::Sections::IsoPreface,
        )
      end
    end
  end
end
