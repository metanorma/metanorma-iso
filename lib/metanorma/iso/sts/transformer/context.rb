# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::Context
        attr_reader :source_document, :id_generator, :footnote_collector

        def initialize(source_document)
          @source_document = source_document
          @id_generator = Transformer::IdGenerator.new(self)
          @footnote_collector = Transformer::FootnoteCollector.new
        end

        def language
          return nil unless @source_document

          bibdata = @source_document.bibdata
          return nil unless bibdata

          lang = bibdata.language
          lang.is_a?(Array) ? lang.first : lang
        end

        def script
          return nil unless @source_document

          bibdata = @source_document.bibdata
          return nil unless bibdata

          scr = bibdata.script
          scr.is_a?(Array) ? scr.first : scr
        end

        def doctype
          bibdata = @source_document.bibdata
          bibdata&.ext&.doctype
        end

        def bibitem_lookup
          @bibitem_lookup ||= build_bibitem_lookup
        end

        private

        def build_bibitem_lookup
          lookup = {}
          bib = @source_document.bibliography
          return lookup unless bib

          bib.references&.each do |ref_section|
            ref_section.references&.each do |bibitem|
              next unless bibitem.id

              lookup[bibitem.id] = bibitem
            end
          end

          lookup
        end
      end
    end
  end
end
