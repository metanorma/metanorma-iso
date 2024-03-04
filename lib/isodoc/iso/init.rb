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

      def update_i18n(docxml)
        @docscheme =
          docxml.at(ns("//presentation-metadata[name" \
                       "[text() = 'document-scheme']]/value"))&.text || "2024"
        %w(1951 1972).include?(@docscheme) and
          i18n_conditional_set("reference_number", "reference_number_abbrev")
        %w(1951).include?(@docscheme) and
          i18n_conditional_set("edition_ordinal", "edition_ordinal_old")
      end

      def i18n_conditional_set(old, new)
        @i18n.get[new] or return
        @i18n.set(old, @i18n.get[new])
      end

      def bibrenderer(options = {})
        ::Relaton::Render::Iso::General.new(options.merge(language: @lang,
                                                          i18nhash: @i18n.get))
      end

      def amd?(_docxml)
        %w(amendment technical-corrigendum).include? @doctype
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
        ids = id.split(/(\p{Zs})/)
        agency?(ids[0].sub(/\/.*$/, "")) or return id
        ids.map! do |i|
          if %w(GUIDE TR TS DIR).include?(i)
            "<span class='stddocNumber'>#{i}</span>"
          elsif /\p{Zs}/.match?(i) then i
          else std_docid_semantic_full(i)
          end
        end.join.gsub(%r{</span>(\p{Zs}+)<}, "\\1</span><")
      end

      def std_docid_semantic_full(ident)
        ident
          .sub(/^([^0-9]+)(\p{Zs}|$)/, "<span class='stdpublisher'>\\1</span>\\2")
          .sub(/([0-9]+)/, "<span class='stddocNumber'>\\1</span>")
          .sub(/-([0-9]+)/, "-<span class='stddocPartNumber'>\\1</span>")
          .sub(/:([0-9]{4})(?!\d)/, ":<span class='stdyear'>\\1</span>")
      end
    end
  end
end
