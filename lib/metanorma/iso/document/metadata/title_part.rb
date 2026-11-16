# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Metadata
      # Title with type="title-part" - part component
      class TitlePart < AbstractTitle
        attribute :semx_id, :string
      end
    end
  end
end
