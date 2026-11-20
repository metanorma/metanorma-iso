# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an Annex section: forces a page break before, sets the
        # annex zone flag (so descendants know they're inside an annex),
        # and uses the dedicated Annex paragraph style for the title.
        class AnnexRenderer < SectionRenderer
          def around_section(_section, doc, &)
            doc.page_break
            @context.section_depth += 1
            @context.with_annex(&)
          ensure
            @context.section_depth -= 1
          end

          def title_style_for(_section)
            @resolver.paragraph_style(:annex)
          end

          private

          # The reference carries, right after each annex heading, a
          # hidden paragraph holding the single-line ToC composition
          # ("Annex C", tab, "Gelatinization") from the presentation
          # XML's variant-title[@type='toc'].
          def render_section_title(section, doc)
            super
            render_variant_title_toc(section, doc)
          end

          # An annex with no title still carries its hidden ToC
          # composition, ahead of the body that holds its id bookmark.
          def render_untitled_section(section, doc)
            render_variant_title_toc(section, doc)
            super
          end

          def render_variant_title_toc(section, doc)
            variant = Array(section.variant_title).find { |v| v.type == "toc" }
            return unless variant

            style = @resolver.paragraph_style(:variant_title_toc) or return

            para = build_unstyled_paragraph
            para.style = style
            @inline_renderer.render(variant, HiddenRuns.new(para))
            doc << para
          end

          # Marks every run it forwards to the paragraph as hidden text.
          # An inline equation (OMML) cannot carry w:vanish, so it is
          # dropped: the paragraph is hidden and the heading and ToC
          # entry already show the equation.
          class HiddenRuns
            def initialize(para)
              @para = para
            end

            def <<(element)
              element = Uniword::Wordprocessingml::Run.new(text: element) if element.is_a?(String)
              element = element.build if element.is_a?(Uniword::Builder::RunBuilder)
              return self if element.is_a?(Omml::Models::CTOMath)

              hide(element)
              if @after_link && element.is_a?(Uniword::Wordprocessingml::Run)
                append_after_link(element)
              else
                @para << element
              end
              @after_link = element.is_a?(Uniword::Wordprocessingml::Hyperlink)
              self
            end

            private

            # ParagraphBuilder merges a run into the previous run even
            # when a hyperlink sits between them, which would move the
            # text before the link. Append the run at its own position.
            def append_after_link(run)
              @para.model.runs << run
              @para.model.element_order << Lutaml::Xml::Element.new("Element", "r")
            end

            def hide(element)
              if element.is_a?(Uniword::Wordprocessingml::Hyperlink)
                Array(element.runs).each { |run| hide(run) }
              end
              return unless element.is_a?(Uniword::Wordprocessingml::Run)

              element.properties ||= Uniword::Wordprocessingml::RunProperties.new
              element.properties.hidden = Uniword::Properties::Vanish.new
            end
          end
        end
      end
    end
  end
end
