# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Metadata
      # Title with type="title-amd" - amendment description text
      class TitleAmd < AbstractTitle
        attribute :semx_id, :string
      end
    end
  end
end
