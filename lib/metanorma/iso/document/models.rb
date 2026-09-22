# frozen_string_literal: true

# Model tree only — no Registers.setup, no flavor-table registration.
# Downstream flavors (itu/ogc/iec) that subclass Iso::* models require
# this file so they get the classes and the IsoDocument alias without
# installing ISO's global type substitutions (which would alter their
# own document parsing).
module Metanorma
  module Iso
  end
end

require "metanorma/document"
require "metanorma/standoc"

module Metanorma
  module Iso::Document
    autoload :AnnotationContainer, "#{__dir__}/annotation_container"
    autoload :Blocks, "#{__dir__}/blocks"
    autoload :Boilerplate, "#{__dir__}/boilerplate"
    autoload :Metadata, "#{__dir__}/metadata"
    autoload :Root, "#{__dir__}/root"
    autoload :Sections, "#{__dir__}/sections"
    autoload :Terms, "#{__dir__}/terms"
  end
end

module Metanorma
  existing = defined?(Metanorma::IsoDocument) && Metanorma::IsoDocument
  if !existing.equal?(Metanorma::Iso::Document)
    Metanorma.send(:remove_const, :IsoDocument) if existing
    IsoDocument = Metanorma::Iso::Document
  end
end
