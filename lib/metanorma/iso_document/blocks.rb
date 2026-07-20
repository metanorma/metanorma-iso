# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Blocks
      autoload :IsoAdmonitionBlock,
               "#{__dir__}/blocks/iso_admonition_block"
      autoload :IsoAdmonitionType,
               "#{__dir__}/blocks/iso_admonition_type"
    end
  end
end
