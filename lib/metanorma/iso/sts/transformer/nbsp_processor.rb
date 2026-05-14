# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::NbspProcessor
        NBSP = " "

        RULES = [
          [/(Part) (\d)/i, "\\1#{NBSP}\\2"],
          [/(\d) (%)/, "\\1#{NBSP}\\2"],
          [/(ISO[\/&]?(?:TC|IEC)?) (\d)/i, "\\1#{NBSP}\\2"],
          [/(NOTE) (\d)/i, "\\1#{NBSP}\\2"],
          [/(Note)\s(\d)\s(to entry)/i, "\\1#{NBSP}\\2#{NBSP}\\3"],
          [/(Table|Figure|Clause|Volume) (([A-Za-z]\.)?\d)/i,
           "\\1#{NBSP}\\2"],
          [/(Formula) (\()/i, "\\1#{NBSP}\\2"],
          [/(Annex) ([A-Za-z])/i, "\\1#{NBSP}\\2"],
          [/ (— [A-Z])/, "#{NBSP}\\1"],
        ].freeze

        def self.process(text)
          return text unless text.is_a?(String)

          RULES.reduce(text) do |t, (pattern, replacement)|
            t.gsub(pattern, replacement)
          end
        end
      end
    end
  end
end
