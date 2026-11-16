# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an IsoTerm: number (with bookmark), preferred/admitted/
        # deprecated designations, definitions, notes, and examples.
        #
        # Each designation kind maps to a dedicated Era C paragraph style:
        #   - preferred → Terms (or TermNum when there's no autonumber)
        #   - admitted  → AltTerms
        #   - deprecated→ DeprecatedTerm (prefixed with "DEPRECATED: " when
        #                 the source doesn't already include that prefix)
        class TermRenderer
          include Base
          include ModelUtils

          DEPRECATED_PREFIX = "DEPRECATED: "
          private_constant :DEPRECATED_PREFIX

          def render(term, doc)
            render_term_number(term, doc)
            render_designations(term, doc)
            render_term_definitions(term, doc)
            render_term_notes(term, doc)
            render_term_examples(term, doc)
            render_term_sources(term, doc)
          end

          private

          def render_term_number(term, doc)
            fmt_name = attribute_value(term, :fmt_name)
            return unless fmt_name

            para = build_unstyled_paragraph
            para.style = @resolver.paragraph_style(:term_num)
            apply_compact_spacing(para)
            with_bookmark(term, para) do
              @inline_renderer.render_heading(fmt_name, para)
            end
            doc << para
          end
          def render_designations(term, doc)
            render_preferred_designations(term, doc)
            render_admitted_designations(term, doc)
            render_deprecated_designations(term, doc)
          end

          def render_preferred_designations(term, doc)
            values = pick_designation_values(term, :fmt_preferred, :preferred)
            style_key = attribute_value(term, :fmt_name) ? :terms : :term_num
            style = @resolver.paragraph_style(style_key)
            values.each do |designation|
              render_designation_paragraphs(designation, doc, style)
            end
          end

          def render_admitted_designations(term, doc)
            values = pick_designation_values(term, :fmt_admitted, :admitted)
            style = @resolver.paragraph_style(:alt_terms)
            values.each do |designation|
              render_designation_paragraphs(designation, doc, style)
            end
          end

          def render_deprecated_designations(term, doc)
            values = pick_designation_values(term, :fmt_deprecates, :deprecates)
            style = @resolver.paragraph_style(:deprecated_term)
            values.each do |designation|
              prefix = deprecated_prefix(designation)
              render_designation_paragraphs(designation, doc, style,
                                            prefix: prefix)
            end
          end

          def pick_designation_values(term, fmt_attr, plain_attr)
            fmt_values = Array(attribute_value(term, fmt_attr))
            return fmt_values if fmt_values.any?

            Array(attribute_value(term, plain_attr))
          end

          def render_designation_paragraphs(designation, doc, style,
prefix: nil)
            return unless designation

            paragraphs = inner_paragraphs(designation)
            if paragraphs.empty?
              return render_designation_run(designation, doc, style, prefix)
            end

            paragraphs.each do |p|
              render_designation_with_prefix(p, doc, style, prefix)
            end
          end

          def render_designation_with_prefix(designation, doc, style, prefix)
            para = build_unstyled_paragraph
            para.style = style
            apply_compact_spacing(para)
            append_prefix(para, prefix)
            @inline_renderer.render(designation, para)
            doc << para
          end

          def render_designation_run(designation, doc, style, prefix)
            para = build_unstyled_paragraph
            para.style = style
            apply_compact_spacing(para)
            append_prefix(para, prefix)
            @inline_renderer.render(designation, para)
            doc << para
          end

          # Compact (no before/after) spacing so TermNum → Terms → AltTerms
          # form one tight block. Definition gets a "before" gap to
          # visually separate it from the designations.
          def apply_compact_spacing(para)
            para.spacing(before: 0, after: 0)
          end

          def apply_definition_spacing(para)
            para.spacing(before: 240, after: 0)
          end

          def append_prefix(para, prefix)
            return unless prefix

            run = Uniword::Builder::RunBuilder.new
            run.text(prefix)
            para << run.build
          end

          def inner_paragraphs(designation)
            return [] unless designation.class.attributes.key?(:p)

            Array(designation.p)
          end

          # Suppress the prefix if the source text already embeds it.
          def deprecated_prefix(designation)
            text = collect_all_text(designation)
            return nil if text&.include?(DEPRECATED_PREFIX)

            DEPRECATED_PREFIX
          end

          def render_term_definitions(term, doc)
            definitions = pick_definition_source(term)
            definitions.each { |defn| render_definition(defn, doc) }
          end

          # Render each <p> of a definition with the Definition paragraph
          # style applied. Walking the definition anonymously would let
          # each <p> inherit the document default style instead.
          def render_definition(defn, doc)
            paragraphs = definition_paragraphs(defn)
            if paragraphs.empty?
              @context.with_note do
                para = build_paragraph(:definition)
                apply_definition_spacing(para)
                @inline_renderer.render(defn, para)
                doc << para
              end
              return
            end

            paragraphs.each do |p|
              para = build_paragraph(:definition)
              apply_definition_spacing(para)
              @inline_renderer.render(p, para)
              doc << para
            end
          end

          def definition_paragraphs(defn)
            return [] unless defn.is_a?(Lutaml::Model::Serializable)

            # fmt-definition has direct <p> children
            return Array(defn.p) if defn.class.attributes.key?(:p) && defn.p

            # definition → verbal-definition → p
            if defn.class.attributes.key?(:verbal_definition)
              vd = defn.verbal_definition
              return Array(vd.p) if vd && vd.class.attributes.key?(:p) && vd.p
            end

            []
          end

          def pick_definition_source(term)
            fmt = attribute_value(term, :fmt_definition)
            return Array(fmt) if fmt

            Array(attribute_value(term, :definition))
          end

          def render_term_notes(term, doc)
            Array(attribute_value(term, :termnote)).each do |tn|
              @context.with_note do
                para = build_paragraph(:note)
                @inline_renderer.render(tn, para)
                doc << para
              end
            end
          end

          def render_term_examples(term, doc)
            Array(attribute_value(term, :termexample)).each do |te|
              @context.with_example do
                render_example_name(te, doc)
                @walker&.walk(te, doc)
              end
            end
          end

          def render_term_sources(term, doc)
            term_sources(term).each do |src|
              para = build_paragraph(:source)
              @inline_renderer.render(src, para)
              doc << para
            end
          end

          # Prefer the presentation-XML fmt_termsource (which already contains
          # the rendered "[SOURCE: ...]" text), then fall back to raw
          # termsource / source elements.
          def term_sources(term)
            fmt = Array(attribute_value(term, :fmt_termsource))
            return fmt if fmt.any?

            raw = Array(attribute_value(term, :termsource))
            return raw if raw.any?

            Array(attribute_value(term, :source))
          end

          def render_example_name(example, doc)
            name = attribute_value(example, :fmt_name) ||
              attribute_value(example, :name)
            return unless name

            para = build_paragraph(:example)
            @inline_renderer.render(name, para)
            doc << para
          end
        end
      end
    end
  end
end
