# frozen_string_literal: true

# Metanorma::IsoDocument — the ISO-specific document model.
#
# This is the canonical home for IsoDocument. It is NOT a vendored copy
# of metanorma-document. The ownership model is:
#
#   metanorma-document  → Metanorma::Document (components, relaton)
#   metanorma-standoc   → Metanorma::StandardDocument (generic standard document)
#   metanorma-iso       → Metanorma::IsoDocument (ISO-specific extensions)
#
# IsoDocument extends StandardDocument with ISO-specific types:
# IsoBibliographicItem, IsoSections, IsoPreface, IsoTermsSection, etc.
#
# Standoc is required eagerly because StandardDocument lives there. Loading
# metanorma/document alone would still resolve StandardDocument while
# metanorma-document ships its legacy copy, but the canonical home is
# metanorma-standoc and the require makes that explicit.
#
# All autoloads below use absolute paths so this tree is self-contained.

require "metanorma/document"
require "metanorma/standoc"

module Metanorma
  module IsoDocument
    autoload :AnnotationContainer, "#{__dir__}/iso_document/annotation_container"
    autoload :Blocks, "#{__dir__}/iso_document/blocks"
    autoload :Boilerplate, "#{__dir__}/iso_document/boilerplate"
    autoload :Metadata, "#{__dir__}/iso_document/metadata"
    autoload :Root, "#{__dir__}/iso_document/root"
    autoload :Sections, "#{__dir__}/iso_document/sections"
    autoload :Terms, "#{__dir__}/iso_document/terms"
  end
end

Metanorma::Registers::Setup.setup_iso_register
