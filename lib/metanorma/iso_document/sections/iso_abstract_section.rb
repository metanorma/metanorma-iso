# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Abstract section in the preface. Same structure as a clause but maps
      # to the "abstract" element.
      class IsoAbstractSection < IsoClauseSection
        xml do
          element "abstract"
        end
      end
    end
  end
end
