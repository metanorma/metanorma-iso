# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Converts MN <quote> blocks (MultiParagraph::QuoteBlock) to
        # NISO STS <disp-quote> — the element mnconvert emits for the
        # same source. The quote's paragraphs render inside the
        # disp-quote; its unordered/ordered lists have no disp-quote
        # slot in the STS model and surface as sibling <list> elements
        # after it (BlockDispatcher#quote_trailing_lists).
        class QuoteTransformer < Base
          def transform(source_quote)
            paragraphs = extract_paragraphs(source_quote)
            attribution = attribution_of(source_quote)
            return nil if paragraphs.empty? && attribution.nil?

            id = id_generator.id_for(source_quote)
            ModelBuilder.disp_quote(id: id, paragraph: paragraphs,
                                    attribution: attribution)
          end

          private

          # Guarded read: only classes that declare the attribute
          # answer it, so blocks lacking the slot yield [] instead of
          # raising.
          def extract_paragraphs(source_quote)
            return [] unless source_quote.class.attributes.key?(:paragraphs)

            Array(source_quote.paragraphs).map { |p| paragraph_transformer.transform(p) }
          end

          # The quote's attribution ("<quote><attribution><p>…")
          # renders as the STS attribution's mixed content text. The
          # AttributionElement itself is not text-walkable — its
          # paragraphs are.
          def attribution_of(source_quote)
            return nil unless source_quote.class.attributes.key?(:attribution)

            text = Array(source_quote.attribution).flat_map do |attr|
              next [] unless attr.class.attributes.key?(:p)
              Array(attr.p).map { |p| RenderedTextExtractor.text_of(p) }
            end.join(" ").strip
            text.empty? ? nil : ::Sts::NisoSts::Attribution.new(content: [text])
          end
        end
      end
    end
  end
end
