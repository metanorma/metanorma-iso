require "asciidoctor"

require "asciidoctor/iso/version"
require "asciidoctor/iso/base"
require "asciidoctor/iso/lists"
require "asciidoctor/iso/inline_anchor"
require "asciidoctor/iso/blocks"
require "asciidoctor/iso/table"
require "asciidoctor/iso/validate"

module Asciidoctor
  module ISO
    # A {Converter} implementation that generates ISO output, and a document
    # schema encapsulation of the document for validation
    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      include ::Asciidoctor::ISO::Base
      include ::Asciidoctor::ISO::Lists
      include ::Asciidoctor::ISO::InlineAnchor
      include ::Asciidoctor::ISO::Blocks
      include ::Asciidoctor::ISO::Table
      include ::Asciidoctor::ISO::Validate

      register_for "iso"

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
      alias_method :inline_callout, :content
    end
  end
end
