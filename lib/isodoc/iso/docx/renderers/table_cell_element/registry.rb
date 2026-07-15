# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Single dispatch point from table cell element class to handler.
          #
          # Replaces TableRenderer's case/when cell-element dispatch with
          # a class-keyed lookup table. Adding a new cell element type is
          # a two-step change:
          #
          #   1. Add a handler class under TableCellElement::*.
          #   2. Register it in +#register_defaults+.
          #
          # No edit to existing dispatch logic — Open/Closed Principle.
          #
          # Lookup is exact-class first, then walks the ancestor chain.
          # When no handler is registered for the element's class or any
          # ancestor, +#dispatch+ falls back to the default ParagraphHandler.
          class Registry
            attr_reader :table, :default, :resolver, :inline_renderer

            def initialize(resolver:, inline_renderer:)
              @resolver = resolver
              @inline_renderer = inline_renderer
              @table = {}
              register_defaults
            end

            def register(klass, handler)
              @table[klass] = handler
            end

            def register_default(handler)
              @default = handler
            end

            def lookup(klass)
              return @table[klass] if @table.key?(klass)

              klass.ancestors.each do |ancestor|
                next unless ancestor.is_a?(Class)
                return @table[ancestor] if @table.key?(ancestor)
              end
              @default
            end

            def dispatch(element, target)
              handler = lookup(element.class)
              handler&.render(element, target)
            end

            def registered?(klass)
              @table.key?(klass)
            end

            private

            def register_defaults
              register_paragraph_handler
              register_note_handler
              register_list_handlers
            end

            def register_paragraph_handler
              paragraph = ParagraphHandler.new(
                resolver: @resolver, inline_renderer: @inline_renderer,
              )
              register(
                Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                paragraph,
              )
              register_default(paragraph)
            end

            def register_note_handler
              register(
                Metanorma::Document::Components::Blocks::NoteBlock,
                NoteHandler.new(
                  resolver: @resolver, inline_renderer: @inline_renderer,
                ),
              )
            end

            def register_list_handlers
              register(
                Metanorma::Document::Components::Lists::OrderedList,
                build_list_handler(:decimal_list),
              )
              register(
                Metanorma::Document::Components::Lists::UnorderedList,
                build_list_handler(:dash_list),
              )
            end

            def build_list_handler(num_id_key)
              ListHandler.new(
                resolver: @resolver,
                inline_renderer: @inline_renderer,
                num_id_key: num_id_key,
              )
            end
          end
        end
      end
    end
  end
end
