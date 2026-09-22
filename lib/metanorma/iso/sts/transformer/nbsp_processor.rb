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
        # Tags are split out and only the text chunks pass through
        # #process — a single linear pass (the previous gsub over
        # +>([^<]+)<+ rescanned each +>+ start position and went
        # polynomial on pathologically repetitive input, CodeQL
        # rb/polynomial-redos).
        #
        # @param xml [String] serialised STS XML.
        # @return [String] XML with NBSP rules applied to text content.
        def self.apply_to_text(xml)
          xml.split(/(<[^>]*>)/).map do |chunk|
            chunk.start_with?("<") ? chunk : process(chunk)
          end.join
        end
      end
    end
  end
end
