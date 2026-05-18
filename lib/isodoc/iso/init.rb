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
        @docscheme ||= "2024"
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
        ::Relaton::Render::Iso::General.new(options
          .merge(language: @lang, script: @script, i18nhash: @i18n.get,
                 config: @relatonrenderconfig))
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
    end
  end
end
