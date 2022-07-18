require "isodoc"
require_relative "metadata"
require_relative "xref"
require_relative "i18n"

module IsoDoc
  module Iso
    module Init
      def metadata_init(lang, script, i18n)
        @meta = Metadata.new(lang, script, i18n)
      end

      def xref_init(lang, script, _klass, i18n, options)
        html = HtmlConvert.new(language: lang, script: script)
        @xrefs = Xref.new(lang, script, html, i18n, options)
      end

      def i18n_init(lang, script, i18nyaml = nil)
        @i18n = I18n.new(lang, script, i18nyaml: i18nyaml || @i18nyaml)
      end

      def amd(docxml)
        doctype = docxml&.at(ns("//bibdata/ext/doctype"))&.text
        %w(amendment technical-corrigendum).include? doctype
      end

      def clausedelim
        ""
      end

      def std_docid_semantic(id)
        return nil if id.nil?

        iso = id.split(/(\s\/)/).any? { |i| /^(IEC|ISO|BSI)/.match?(i) }
        id.split(/ /).map.with_index do |x, i|
          iso ? std_docis_iso_parse(x) : std_docis_sdo_parse(x, i)
        end.join(" ")
      end

      def std_docis_iso_parse(ident)
        %w(GUIDE TR TS DIR).include?(ident) and
          return "<span class='stddocNumber'>#{ident}</span>"
        ident.sub(/^([^0-9]+)(\s|$)/, "<span class='stdpublisher'>\\1</span>\\2")
          .sub(/([0-9]+)/, "<span class='stddocNumber'>\\1</span>")
          .sub(/-([0-9]+)/, "-<span class='stddocPartNumber'>\\1</span>")
          .sub(/:([0-9]{4})(?!\d)/, ":<span class='stdyear'>\\1</span>")
      end

      def std_docis_sdo_parse(ident, idx)
        idx.zero? and return "<span class='stdpublisher'>#{ident}</span>"
        ident
          .sub(/([:-])((19|20)[0-9]{2})$/, "\\1<span class='stdyear'>\\2</span>")
          .sub(/^(.*?)([:-]<|$)/, "<span class='stddocNumber'>\\1</span>\\2")
      end
    end
  end
end
