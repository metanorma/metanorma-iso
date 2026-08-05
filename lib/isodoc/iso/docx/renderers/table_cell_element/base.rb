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
          # construction.
          #
          # Subclasses MUST implement +render(element, target)+.
          module Base
            attr_reader :resolver, :inline_renderer

            def initialize(resolver:, inline_renderer:)
              @resolver = resolver
              @inline_renderer = inline_renderer
            end
          end
        end
      end
    end
  end
end
