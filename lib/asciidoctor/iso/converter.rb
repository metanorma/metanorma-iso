require "asciidoctor"
require "metanorma-standoc"
require "asciidoctor/iso/version"
require "asciidoctor/iso/base"
require "asciidoctor/iso/front"
#require "asciidoctor/iso/ref"
#require "asciidoctor/iso/section"
#require "asciidoctor/iso/validate"
#require "asciidoctor/iso/utils"
require "asciidoctor/iso/cleanup"

module Asciidoctor
  module ISO
    # A {Converter} implementation that generates ISO output, and a document
    # schema encapsulation of the document for validation
    class Converter < ::Asciidoctor::Standoc::Converter
      register_for "iso"

    end
  end
end
