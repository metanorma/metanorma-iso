# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Title with type="title-part-prefix" - part prefix (e.g., "Part 1")
      class TitlePartPrefix < AbstractTitle
        attribute :semx_id, :string
      end
    end
  end
end
