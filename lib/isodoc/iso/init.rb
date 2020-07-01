require "isodoc"
require_relative "metadata"
require_relative "xref"

module IsoDoc
  module Iso
    module Init
      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def xref_init(lang, script, klass, labels, options)
        @xrefs = Xref.new(lang, script, HtmlConvert.new(language: lang, script: script), labels, options)
      end

      def amd(docxml)
        doctype = docxml&.at(ns("//bibdata/ext/doctype"))&.text
        %w(amendment technical-corrigendum).include? doctype
      end
    end
  end
end

