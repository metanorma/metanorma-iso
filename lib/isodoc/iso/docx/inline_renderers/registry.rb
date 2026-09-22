# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Single dispatch point from inline element class to handler object.
        #
        # The Registry replaces InlineRenderer's case/when dispatch with a
        # class-keyed lookup table. Adding a new inline type is a two-step
        # change:
        #
        #   1. Add a handler class under InlineRenderers::*.
        #   2. Register it in +#register_defaults+.
        #
        # No edit to existing dispatch logic — Open/Closed Principle.
        #
        # Lookup is exact-class first, then walks the ancestor chain so
        # that, e.g., +EmphasisElement+ matches a registered +EmRawElement+
        # if both share a common ancestor that is registered.
        #
        # When no handler is registered for the element's class or any
        # ancestor, +#dispatch+ falls back to the parent InlineRenderer's
        # default text-collection behavior.
        class Registry
          attr_reader :parent, :table

          def initialize(parent)
            @parent = parent
            @table = {}
            register_defaults
          end

          def register(klass, handler)
            @table[klass] = handler
          end

          # Returns the handler registered for +klass+, walking ancestors
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

          # Dispatch +element+ to its registered handler. Returns whatever
          # the handler returns (typically +nil+; the handler's effect is
          # via mutations on +para+). When no handler is registered, falls
          # back to the parent's default text-collection behavior.
          def dispatch(element, para)
            handler = lookup(element.class)
            if handler
              handler.render(element, para)
            else
              parent.render_unmatched_element(element, para)
            end
          end

          def registered?(klass)
            @table.key?(klass)
          end

          private

          # One +#register+ call per supported inline element type.
          # Adding a new type = add a class + add a register line.
          def register_defaults
            register(Metanorma::Document::Components::Inline::EmRawElement,
                     ItalicRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::EmphasisElement,
                     ItalicRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::StrongRawElement,
                     BoldRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::StrongElement,
                     BoldRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::SubElement,
                     SubscriptRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::SubscriptElement,
                     SubscriptRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::SupElement,
                     SuperscriptRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::SuperscriptElement,
                     SuperscriptRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::TtElement,
                     MonospaceRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::MonospaceElement,
                     MonospaceRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::StrikeElement,
                     StrikethroughRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::UnderlineElement,
                     UnderlineRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::KeywordElement,
                     KeywordRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::SmallCapsElement,
                     SmallCapRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::SmallCapElement,
                     SmallCapRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::BrElement,
                     BreakRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::TabElement,
                     TabRenderer.new(parent))
            register(Metanorma::Document::Components::EmptyElements::PageBreakElement,
                     PageBreakRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::LinkElement,
                     LinkRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::XrefElement,
                     XrefRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::ErefElement,
                     ErefRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FnElement,
                     FootnoteRenderer.new(parent))
            register(Metanorma::Document::Components::ReferenceElements::Callout,
                     CalloutRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FmtStemElement,
                     StemRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::StemInlineElement,
                     StemRenderer.new(parent))
            register(Metanorma::Document::Components::TextElements::StemElement,
                     StemRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::MathElement,
                     NullRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::AsciimathElement,
                     AsciimathRenderer.new(parent))
            register(Metanorma::Document::Components::IdElements::Image,
                     ImageRenderer.new(parent))
            register(Metanorma::Document::Components::IdElements::Bookmark,
                     BookmarkRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::Bcp14Element,
                     Bcp14Renderer.new(parent))
            register(Metanorma::Document::Components::Inline::SpanElement,
                     SpanRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::SemxElement,
                     SemxRenderer.new(parent))
            register(Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                     MixedInlineFallbackRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FmtXrefElement,
                     FmtXrefRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FmtXrefLabelElement,
                     NullRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
                     AnnotationStartRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FmtFnLabelElement,
                     AnnotationStartRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
                     AnnotationStartRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
                     AnnotationEndRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FmtTitleElement,
                     MixedInlineFallbackRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::FmtNameElement,
                     MixedInlineFallbackRenderer.new(parent))
            register(Metanorma::Iso::Document::Terms::TermExpression,
                     TermExpressionRenderer.new(parent))
            register(Metanorma::Iso::Document::Terms::TermNameElement,
                     TermNameRenderer.new(parent))
            register(Metanorma::Document::Components::Inline::VariantTitleElement,
                     MixedInlineFallbackRenderer.new(parent))
          end
        end
      end
    end
  end
end
