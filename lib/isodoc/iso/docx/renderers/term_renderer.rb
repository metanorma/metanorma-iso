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
          include BoxWrapper
          include NoteContent

          DEPRECATED_PREFIX = "DEPRECATED: "
          private_constant :DEPRECATED_PREFIX

          DEFINITION_PARAGRAPH = Metanorma::Document::Components::Paragraphs::ParagraphBlock
          DEFINITION_BLOCKS = [
            DEFINITION_PARAGRAPH,
            Metanorma::Document::Components::Lists::OrderedList,
            Metanorma::Document::Components::Lists::UnorderedList,
            Metanorma::Document::Components::Lists::DefinitionList,
            Metanorma::Document::Components::Tables::TableBlock,
            Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
            Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
            Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
            Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
            Metanorma::Document::Components::Blocks::NoteBlock,
            Metanorma::Document::Components::MultiParagraph::QuoteBlock,
            Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
          ].freeze
          private_constant :DEFINITION_PARAGRAPH, :DEFINITION_BLOCKS

          def render(term, doc)
            render_term_number(term, doc)
            render_designations(term, doc)
            render_term_definitions(term, doc)
            render_term_trailing_blocks(term, doc)
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

          # Definition paragraphs take the Definition style. Lists, tables,
          # formulas and other blocks go through normal dispatch, in order.
          def render_definition(defn, doc)
            blocks = definition_blocks(defn)
            return render_inline_definition(defn, doc) if blocks.empty?

            blocks.each_with_index do |block, index|
              if block.is_a?(DEFINITION_PARAGRAPH)
                render_definition_paragraph(block, doc, index.zero? ? defn : nil)
              else
                @walker.dispatch(block, doc)
              end
            end
          end

          def render_definition_paragraph(paragraph, doc, owner)
            @context.with_note do
              para = build_paragraph(:definition)
              apply_definition_spacing(para)
              @inline_renderer.render(paragraph, para)
              anchor_paragraph(paragraph, para)
              anchor_paragraph(owner, para) if owner
              doc << para
            end
          end

          def render_inline_definition(defn, doc)
            @context.with_note do
              para = build_paragraph(:definition)
              apply_definition_spacing(para)
              @inline_renderer.render(defn, para)
              anchor_paragraph(defn, para)
              doc << para
            end
          end

          def definition_blocks(defn)
            return [] unless defn.is_a?(Lutaml::Model::Serializable)

            source = attribute_value(defn, :verbal_definition) || defn
            block_children(source).select do |child|
              DEFINITION_BLOCKS.any? { |klass| child.is_a?(klass) }
            end
          end

          def pick_definition_source(term)
            fmt = attribute_value(term, :fmt_definition)
            return Array(fmt) if fmt

            Array(attribute_value(term, :definition))
          end

          TRAILING_ATTRS = %i[termnote termexample sourcecode quote admonition].freeze
          private_constant :TRAILING_ATTRS

          # Notes, examples and term-level blocks follow the definition in
          # source order. A term parsed without element order falls back to
          # notes, examples, then the other blocks.
          def render_term_trailing_blocks(term, doc)
            trailing_blocks(term).each do |block|
              case block
              when Metanorma::Iso::Document::Terms::TermNote
                render_term_note(block, doc)
              when Metanorma::Iso::Document::Terms::TermExample
                render_term_example(block, doc)
              else
                @walker.dispatch(block, doc)
              end
            end
          end

          def trailing_blocks(term)
            return TRAILING_ATTRS.flat_map { |attr| Array(attribute_value(term, attr)) } unless ordered?(term)

            blocks = []
            each_ordered_element(term, allow_filter: TRAILING_ATTRS) do |_type, child|
              blocks << child
            end
            blocks
          end

          def render_term_note(note, doc)
            @context.with_note do
              unless single_note_paragraph?(note)
                with_inline_label(note, doc, :note)
                next
              end

              para = build_paragraph(:note)
              children = block_children(note)
              append_label(para, label_text(note), inline: children.any?)
              children.each { |child| @inline_renderer.render(child, para) }
              anchor_paragraph(note, para)
              Array(attribute_value(note, :p)).each do |p|
                anchor_paragraph(p, para)
              end
              doc << para
            end
          end

          def render_term_example(example, doc)
            @context.with_example do
              render_example_name(example, doc)
              @walker&.walk(example, doc)
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
            anchor_paragraph(example, para)
            doc << para
          end
        end
      end
    end
  end
end
