# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Title with type="title-amendment-prefix" - amendment prefix (e.g. "AMENDMENT 1")
      class TitleAmendmentPrefix < AbstractTitle
        attribute :semx_id, :string
      end
    end
  end
end
