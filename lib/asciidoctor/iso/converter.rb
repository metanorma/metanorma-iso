require "asciidoctor"

require "asciidoctor/iso/version"
require "asciidoctor/iso/base"
require "asciidoctor/iso/validate"

module Asciidoctor
  module ISO
    # A {Converter} implementation that generates ISO output, and a document
    # schema encapsulation of the document for validation
    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      include ::Asciidoctor::ISO::Base
      include ::Asciidoctor::ISO::Validate

      register_for "iso"

      $seen_back_matter = false
      $xreftext = {}

      def initialize(backend, opts)
        super
        basebackend "html"
        outfilesuffix ".xml"
      end

      # alias_method :pass, :content
      alias_method :embedded, :content
      alias_method :sidebar, :content
      alias_method :audio, :skip
      alias_method :colist, :skip
      alias_method :page_break, :skip
      alias_method :thematic_break, :skip
      alias_method :video, :skip
      alias_method :inline_button, :skip
      alias_method :inline_kbd, :skip
      alias_method :inline_menu, :skip
      alias_method :inline_image, :skip

      alias_method :quote, :paragraph
    end
  end
end
