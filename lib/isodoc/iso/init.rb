require "isodoc"
require_relative "metadata"
require_relative "xref"
require_relative "i18n"

module IsoDoc
  module Iso
    module Init
      def metadata_init(lang, script, locale, i18n)
        @meta = Metadata.new(lang, script, locale, i18n)
      end

      def xref_init(lang, script, _klass, i18n, options)
        html = HtmlConvert.new(language: lang, script: script)
        @xrefs = Xref.new(lang, script, html, i18n, options)
      end

      def i18n_init(lang, script, locale, i18nyaml = nil)
        @i18n = I18n.new(lang, script, locale: locale,
                                       i18nyaml: i18nyaml || @i18nyaml)
      end

      def amd(docxml)
        doctype = docxml.at(ns("//bibdata/ext/doctype"))&.text
        %w(amendment technical-corrigendum).include? doctype
      end

      def clausedelim
        ""
      end

      def requirements_processor
        ::Metanorma::Requirements::Iso
      end

      def std_docid_semantic(id)
        id.nil? and return nil
        ret = Nokogiri::XML.fragment(id)
        ret.traverse do |x|
          x.text? or next
          x.replace(std_docid_semantic1(x.text))
        end
        to_xml(ret)
      end

      def std_docid_semantic1(id)
        ids = id.split(/ /)
        %w(ISO IEC ITU IETF NIST OGC IEEE BIPM BSI IANA UN W3C IEV)
          .include?(ids[0].sub(/\/.*$/, "")) or
          return id
        ids.map! do |i|
          if %w(GUIDE TR TS DIR).include?(i)
            "<span class='stddocNumber'>#{i}</span>"
          else std_docid_semantic_full(i)
          end
        end.join(" ")
      end

      def std_docid_semantic_full(ident)
        ident
          .sub(/^([^0-9]+)(\s|$)/, "<span class='stdpublisher'>\\1</span>\\2")
          .sub(/([0-9]+)/, "<span class='stddocNumber'>\\1</span>")
          .sub(/-([0-9]+)/, "-<span class='stddocPartNumber'>\\1</span>")
          .sub(/:([0-9]{4})(?!\d)/, ":<span class='stdyear'>\\1</span>")
      end
    end
  end
end
