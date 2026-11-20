# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Shared infrastructure for per-element-type table cell handlers.
          #
          # A TableCellElement handler renders one kind of model element
          # (paragraph, note, ordered list, etc.) into a CellTarget. All
          # handlers receive the resolver and inline_renderer at
          # construction. A handler whose element can hold further block
          # content also gets the +dispatcher+, a callable taking
          # (element, target) that renders any cell element, nested
          # tables included.
          #
          # Subclasses MUST implement +render(element, target)+.
          module Base
            attr_reader :resolver, :inline_renderer, :dispatcher

            def initialize(resolver:, inline_renderer:, dispatcher: nil)
              @resolver = resolver
              @inline_renderer = inline_renderer
              @dispatcher = dispatcher
            end
          end
        end
      end
    end
  end
end
