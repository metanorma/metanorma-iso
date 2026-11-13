# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Title with type="title-intro" - introductory component
      class TitleIntro < AbstractTitle
        attribute :semx_id, :string
      end
    end
  end
end
