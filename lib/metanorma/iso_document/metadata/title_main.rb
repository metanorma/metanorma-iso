# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Title with type="title-main" - main component
      class TitleMain < AbstractTitle
        attribute :semx_id, :string
      end
    end
  end
end
