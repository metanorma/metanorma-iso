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
      # for the document's primary language. No hardcoded strings.
      class MiddleTitleRenderer
        TITLE_SEPARATOR = " — "
        private_constant :TITLE_SEPARATOR

        def initialize(resolver:, inline_renderer:)
          @resolver = resolver
          @inline_renderer = inline_renderer
        end

        def render(model, doc)
          bib = bibdata(model)
          return unless bib

          render_main(bib, doc)
          render_part(bib, doc)
          render_amd(bib, doc)
        end

        private

        def bibdata(model)
          return nil unless model.class.attributes.key?(:bibdata)

          model.bibdata
        end

        def render_main(bib, doc)
          text = main_text(bib)
          return if text.nil? || text.empty?

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:main_title1)
          para << text
          doc << para
        end

        def render_part(bib, doc)
          text = part_text(bib)
          return if text.nil? || text.empty?

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:main_title2)
          para << text
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
        def render_amd(bib, doc)
          localized = english_title(bib)
          return unless localized

          label = localized.title_amendment_prefix&.value.to_s.strip
          description = localized.title_amd&.value.to_s.strip
          return if label.empty? && description.empty?

          text = label.empty? ? description : "#{label}: #{description}"
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:main_title2)
          para << text
          doc << para
        end

        def main_text(bib)
          localized = english_title(bib)
          return nil unless localized

          parts = []
          parts << localized.title_intro.value if localized.title_intro
          parts << localized.title_main.value if localized.title_main
          parts << localized.title_full.value if localized.title_full && !localized.title_main
          parts.empty? ? nil : parts.join(TITLE_SEPARATOR)
        end

        def part_text(bib)
          localized = english_title(bib)
          return nil unless localized&.title_part

          prefix = localized.title_part_prefix&.value.to_s.strip
          part_val = localized.title_part.value
          return nil if part_val.nil? || part_val.to_s.empty?

          if !prefix.empty?
            sep = prefix.end_with?(":") ? " " : ": "
            "#{prefix}#{sep}#{part_val}"
          else
            part_val.to_s
          end
        end

        def english_title(bib)
          return nil unless bib.class.attributes.key?(:titles)

          titles = bib.titles
          return nil unless titles.is_a?(Metanorma::Iso::Document::Metadata::TitleCollection)

          titles.for_language("en")
        rescue StandardError
          nil
        end
      end
    end
  end
end
