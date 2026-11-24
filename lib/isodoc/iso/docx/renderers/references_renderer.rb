# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a normative references section (<references normative="true">)
        # or informative bibliography section as a heading paragraph followed
        # by an optional intro paragraph and the list of bibliographic items.
        #
        # The section follows clause heading depth from fmt-title but
        # contains <bibitem> children that are dispatched to
        # BibliographyRenderer. Without this renderer the section's
        # children were walked as anonymous mixed content — the title,
        # intro, and bibitems all collapsed into a single paragraph.
        class ReferencesRenderer
          include Base
          include ModelUtils

          def render(section, doc)
            @context.section_depth += 1
            @context.with_bibliography do
              is_normative = normative?(section)
              @context.with_normative(is_normative) do
                render_heading(section, doc)
                render_intro(section, doc)
                render_bibitems(section, doc)
                render_admonitions(section, doc)
              end
            end
          ensure
            @context.section_depth -= 1
          end

          private

          def normative?(section)
            return false unless section.class.attributes.key?(:normative)

            section.normative.to_s == "true"
          end

          def render_heading(section, doc)
            title = section.fmt_title if section.class.attributes.key?(:fmt_title)
            title ||= section.title if section.class.attributes.key?(:title)
            return unless title

            para = build_unstyled_paragraph
            style = @resolver.heading_style([@context.section_depth, 6].min)
            para.style = style if style
            with_bookmark(section, para) do
              @inline_renderer.render_heading(title, para)
            end
            doc << para
          end

          def render_intro(section, doc)
            return unless section.class.attributes.key?(:p)

            Array(section.p).each do |p|
              para = build_unstyled_paragraph
              @inline_renderer.render(p, para)
              doc << para
            end
          end

          def render_bibitems(section, doc)
            return unless section.class.attributes.key?(:references)

            Array(section.references).each do |bib|
              @walker.dispatch(bib, doc)
            end
          end

          # Admonition children of the references section (e.g. an
          # `[EDITOR]` editorial note following the reference list) render
          # after the entries — 1.17.0 carried them ("EDITORIAL NOTE — …");
          # the model dropped them at ingest until the section gained the
          # admonition mapping (metanorma-iso#1764).
          def render_admonitions(section, doc)
            return unless section.class.attributes.key?(:admonition)

            Array(section.admonition).each do |admonition|
              @walker.dispatch(admonition, doc)
            end
          end
        end
      end
    end
  end
end
