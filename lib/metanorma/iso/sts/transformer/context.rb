# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::Context
        attr_reader :source, :id_generator, :footnote_collector

        # Accepts a {Transformer::SourceDocument}, a raw
        # {Metanorma::Iso::Document::Root}, or +nil+ (legacy test fixtures
        # build contexts without a source). Internally always stores a
        # {SourceDocument} so transformers have a uniform accessor surface.
        def initialize(source)
          @source = coerce_source(source)
          @id_generator = Transformer::IdGenerator.new(self)
          @footnote_collector = Transformer::FootnoteCollector.new
        end

        def language
          @source&.language
        end

        def script
          return nil unless @source

          bibdata = @source.bibdata
          return nil unless bibdata

          scr = bibdata.script
          scr.is_a?(Array) ? scr.first : scr
        end

        def doctype
          @source&.bibdata&.ext&.doctype
        end

        def bibitem_lookup
          @bibitem_lookup ||= build_bibitem_lookup
        end

        private

        def coerce_source(input)
          return input if input.is_a?(Transformer::SourceDocument)
          return nil if input.nil?

          Transformer::SourceDocument.new(input)
        end

        def build_bibitem_lookup
          lookup = {}
          bibitems = @source ? @source.bibitems : []
          bibitems.each do |bibitem|
            next unless bibitem.id

            lookup[bibitem.id] = bibitem
          end

          lookup
        end
      end
    end
  end
end
