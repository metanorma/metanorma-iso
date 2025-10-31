require "asciidoctor"
require "metanorma-standoc"
require "metanorma/iso/version"
require "metanorma/iso/base"
require "metanorma/iso/front"
require "metanorma/iso/section"
require "metanorma/iso/validate"
require "metanorma/iso/cleanup"

module Metanorma
  module Iso
    # A {Converter} implementation that generates ISO output, and a document
    # schema encapsulation of the document for validation
    class Converter < ::Metanorma::Standoc::Converter
      register_for "iso"
    end
  end
end

require "metanorma/iso/log"
