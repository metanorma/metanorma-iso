require "asciidoctor"
require "asciidoctor/iso/version"
require "asciidoctor/iso/isoxml/base"
require "asciidoctor/iso/isoxml/front"
require "asciidoctor/iso/isoxml/lists"
require "asciidoctor/iso/isoxml/inline_anchor"
require "asciidoctor/iso/isoxml/blocks"
require "asciidoctor/iso/isoxml/section"
require "asciidoctor/iso/isoxml/table"
require "asciidoctor/iso/isoxml/validate"
require "asciidoctor/iso/isoxml/utils"
require "asciidoctor/iso/isoxml/cleanup"

module Asciidoctor
  module ISO
    # A {Converter} implementation that generates ISO output, and a document
    # schema encapsulation of the document for validation
    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      include ::Asciidoctor::ISO::ISOXML::Base
      include ::Asciidoctor::ISO::ISOXML::Front
      include ::Asciidoctor::ISO::ISOXML::Lists
      include ::Asciidoctor::ISO::ISOXML::InlineAnchor
      include ::Asciidoctor::ISO::ISOXML::Blocks
      include ::Asciidoctor::ISO::ISOXML::Section
      include ::Asciidoctor::ISO::ISOXML::Table
      include ::Asciidoctor::ISO::ISOXML::Utils
      include ::Asciidoctor::ISO::ISOXML::Cleanup
      include ::Asciidoctor::ISO::ISOXML::Validate

      register_for "iso"

      $xreftext = {}

      def initialize(backend, opts)
        super
        basebackend "html"
        outfilesuffix ".xml"
      end

      # alias_method :pass, :content
      alias_method :embedded, :content
      alias_method :aside, :admonition
      alias_method :verse, :quote
      alias_method :literal, :content
      alias_method :audio, :skip
      alias_method :thematic_break, :skip
      alias_method :video, :skip
      alias_method :inline_button, :skip
      alias_method :inline_kbd, :skip
      alias_method :inline_menu, :skip
      alias_method :inline_image, :skip
    end
  end
end
