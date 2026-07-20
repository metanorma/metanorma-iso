# frozen_string_literal: true

# Vendored copy of Metanorma::IsoDocument (from the metanorma-document gem).
#
# The ISO document model lives in this repository so metanorma-iso can iterate
# on it directly (same approach as metanorma-oiml owning its document Root).
# All autoloads below use absolute paths so this copy always shadows the
# metanorma-document gem's lib/metanorma/iso_document* files, regardless of
# $LOAD_PATH order.
#
# Keep in sync with: ../metanorma-document/lib/metanorma/iso_document/

require "metanorma/document"

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
