# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Single dispatch point from model class to renderer object.
        #
        # The Registry replaces the Adapter's +case/when+ dispatch chain
        # with a class-keyed lookup table. Adding a new content type is
        # a two-step change:
        #
        #   1. Add a renderer class (under Renderers::*).
        #   2. Register it in +#build_table+.
        #
        # No edit to existing dispatch logic — Open/Closed Principle.
        #
        # Lookup is exact-class first, then walks the ancestor chain to
        # find a registered base class. This preserves the previous
        # case/when semantics where, e.g., +IsoClauseSection+ matches
        # the +ParagraphBlock+ base branch if no specific entry exists.
        class Registry
          attr_reader :table

          def initialize
            @table = {}
            yield self if block_given?
          end

          def register(klass, renderer)
            @table[klass] = renderer
          end

          # Returns the renderer registered for +klass+, walking ancestors
          # if no exact match exists. Returns +nil+ if no ancestor is
          # registered.
          def lookup(klass)
            return @table[klass] if @table.key?(klass)

            klass.ancestors.each do |ancestor|
              next unless ancestor.is_a?(Class)
              return @table[ancestor] if @table.key?(ancestor)
            end
            nil
          end

          # Dispatch +node+ to its registered renderer. Returns whatever
          # the renderer returns (typically +nil+; the renderer's effect
          # is via mutations on +doc+). Returns +nil+ without raising if
          # no renderer is registered for +node.class+.
          def dispatch(node, doc)
            renderer = lookup(node.class)
            renderer&.render(node, doc)
          end

          def registered?(klass)
            @table.key?(klass)
          end
        end
      end
    end
  end
end
