# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders the middle title page — the document title shown on its
      # own page between front matter (roman) and body (arabic).
      #
      # Era C layout:
      #   - MainTitle1 paragraph for title intro + main (or full)
      #   - MainTitle2 paragraph for title part (with optional prefix)
      #
      # Title text is sourced from bibdata.titles (TitleCollection)
      # for the document's language. No hardcoded title strings.
      class MiddleTitleRenderer
        TITLE_SEPARATOR = " — "
        private_constant :TITLE_SEPARATOR

        # The DIS Word stylesheet sets zzSTDTitle to blue.
        DIS_COLOR = "0000FF"

        def initialize(resolver:, inline_renderer:, color: nil)
          @resolver = resolver
          @inline_renderer = inline_renderer
          @color = color
        end

        def render(model, doc)
          bib = bibdata(model)
          return unless bib

          localized = localized_title(bib, document_language(bib))
          return unless localized

          render_main(localized, doc)
          render_part(localized, doc)
          render_amd(localized, doc)
        end

        private

        def bibdata(model)
          return nil unless model.class.attributes.key?(:bibdata)

          model.bibdata
        end

        def document_language(bib)
          language = Array(bib.language).first if bib.class.attributes.key?(:language)
          value = language.is_a?(String) ? language : language&.value
          code = value.to_s.split(/[-_]/).first.to_s
          code.empty? ? "en" : code
        end

        def render_main(localized, doc)
          text = main_text(localized)
          return if text.nil? || text.empty?

          append_title(doc, :main_title1, text)
        end

        def render_part(localized, doc)
          text = part_text(localized)
          return if text.nil? || text.empty?

          append_title(doc, :main_title2, text)
        end

        def append_title(doc, style_key, text)
          run = Uniword::Builder::RunBuilder.new
          run.text(text)
          run.color(@color) if @color
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(style_key)
          para << run.build
          doc << para
        end

        # Amendment title block: "AMENDMENT 1: <description>" as the
        # middle-title line following the part title. Mirrors the
        # ISO-proven amendment surface (submitted artifacts carry the
        # label + description as a single title line; the classic chain
        # emitted it as the zzSTDTitle2 paragraph from doctitleamdlabel
        # + doctitleamd). MainTitle2 keeps the title family formatting —
        # neither vendored template defines a zzSTDTitle2 style, so the
        # line must reuse a defined styleId (metanorma-iso#1728).
        def render_amd(localized, doc)
          label = localized.title_amendment_prefix&.value.to_s.strip
          description = localized.title_amd&.value.to_s.strip
          return if label.empty? && description.empty?

          text = label.empty? ? description : "#{label}: #{description}"
          append_title(doc, :main_title2, text)
        end

        def main_text(localized)
          parts = []
          parts << localized.title_intro.value if localized.title_intro
          parts << localized.title_main.value if localized.title_main
          parts << localized.title_full.value if localized.title_full && !localized.title_main
          parts.reject { |text| text.to_s.strip.empty? }.join(TITLE_SEPARATOR)
        end

        def part_text(localized)
          return nil unless localized.title_part

          prefix = localized.title_part_prefix&.value.to_s.strip
          part_val = localized.title_part.value
          return nil if part_val.nil? || part_val.to_s.strip.empty?

          if prefix.empty?
            part_val.to_s
          else
            sep = prefix.end_with?(":") ? " " : ": "
            "#{prefix}#{sep}#{part_val}"
          end
        end

        def localized_title(bib, language)
          return nil unless bib.class.attributes.key?(:titles)

          titles = bib.titles
          return nil unless titles.is_a?(Metanorma::Iso::Document::Metadata::TitleCollection)

          candidates = [titles.for_language(language), titles.for_language("en")]
          candidates.concat(Array(titles.per_language)).compact.find do |title|
            [main_text(title), part_text(title), title.title_amd&.value,
             title.title_amendment_prefix&.value].any? { |text| !text.to_s.strip.empty? }
          end
        rescue StandardError
          nil
        end
      end
    end
  end
end
