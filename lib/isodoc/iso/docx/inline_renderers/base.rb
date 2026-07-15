# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Shared infrastructure for per-element inline renderers.
        #
        # An InlineRenderer handler renders one kind of model element
        # (italic, link, footnote, etc.) into a ParagraphBuilder. All
        # handlers receive the parent InlineRenderer (which owns shared
        # state and helpers) at construction.
        #
        # Subclasses MUST implement +render(element, para)+.
        #
        # Open/Closed: adding a new inline type = new handler class + one
        # +register+ call in Registry#register_defaults. No edit to
        # existing dispatch logic.
        module Base
          attr_reader :parent

          def initialize(parent)
            @parent = parent
          end

          # Convenience delegators for the most commonly used helpers.
          # Handlers may also call +parent.<method>+ directly for any
          # helper not listed here.
          def resolver
            parent.resolver
          end

          def context
            parent.context
          end

          def doc
            parent.doc
          end
        end
      end
    end
  end
end
