# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders the colophon — end-of-document metadata section whose
      # clauses are walked through the normal renderer pipeline.
      class ColophonRenderer
        def initialize(walker:)
          @walker = walker
        end

        def render(colophon, doc)
          return unless colophon
          return unless colophon.class.attributes.key?(:clause)

          Array(colophon.clause).each do |clause|
            @walker.walk(clause, doc)
          end
        end
      end
    end
  end
end
