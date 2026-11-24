# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Blocks
      autoload :NoteBlock, "#{__dir__}/blocks/note_block"
      autoload :FormulaBlock, "#{__dir__}/blocks/formula_block"
      autoload :IsoAdmonitionBlock,
               "#{__dir__}/blocks/iso_admonition_block"
      autoload :IsoAdmonitionType,
               "#{__dir__}/blocks/iso_admonition_type"
    end
  end
end
