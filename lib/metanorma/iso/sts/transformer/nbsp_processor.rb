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

        # Apply the NBSP rules to every text node of a serialised XML string.
        # Used as the metanorma-core +document_transformers+ +:post_process+
        # hook, replacing the previously-private
        # DocumentTransformer#apply_nbsp_to_text.
        #
        # Tags are extracted with index arithmetic instead of a quantified
        # regex: a scanning regex (gsub or split) retries every '<' start
        # position and goes polynomial on pathologically repetitive input
        # (CodeQL rb/polynomial-redos). One index walk is linear.
        #
        # @param xml [String] serialised STS XML.
        # @return [String] XML with NBSP rules applied to text content.
        def self.apply_to_text(xml)
          out = +""
          pos = 0
          while (tag_start = xml.index("<", pos))
            out << process(xml.slice(pos...tag_start))
            tag_end = xml.index(">", tag_start)
            if tag_end
              out << xml.slice(tag_start..tag_end)
              pos = tag_end + 1
            else
              out << process(xml.slice(tag_start..))
              pos = xml.length
            end
          end
          out << process(xml.slice(pos..)) if pos < xml.length
          out
        end
      end
    end
  end
end
