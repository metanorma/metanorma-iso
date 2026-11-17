# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module OutputSanitizer
        # Uniquifies +id+ attribute values, which are typed +xs:ID+ in
        # NISO STS and must be unique across the document.
        #
        # mnconvert derives section ids from the section type (a
        # document with two "Scope" clauses emits two +<sec
        # id="sec_scope">+ elements). The first occurrence keeps the
        # value; later occurrences gain a numeric suffix, skipping any
        # suffix that would collide with an unrelated id. Existing
        # +@rid+ references keep resolving to the retained first
        # occurrence, which is the resolution they had before the split.
        class UniqueIdSanitizer
          class << self
            # @param doc [Nokogiri::XML::Document] the parsed STS document.
            # @return [Nokogiri::XML::Document] the same document.
            def apply(doc)
              nodes = doc.xpath("//*[@id]")
              taken = nodes.map { |node| node.attr("id") }.tally
              occurrences = Hash.new(0)

              nodes.each do |node|
                value = node.attr("id")
                occurrences[value] += 1
                next if occurrences[value] == 1

                node["id"] = unique_variant(value, taken)
              end
              doc
            end

            private

            def unique_variant(value, taken)
              index = 1
              index += 1 while taken.key?("#{value}_#{index}")
              candidate = "#{value}_#{index}"
              taken[candidate] = 1
              candidate
            end
          end
        end
      end
    end
  end
end
