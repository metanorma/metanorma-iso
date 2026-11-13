# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Title with type="main" - full/complete title
      class TitleFull < AbstractTitle
        attribute :semx_id, :string
      end
    end
  end
end
