# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module OutputSanitizer
        # Maps inline +<identifier>+ elements to
        # +<named-content content-type="identifier">+.
        #
        # Metanorma requirements and register models emit bare
        # +<identifier>+ inline elements (requirement paths, register
        # URIs, URN namespaces). NISO STS declares no +identifier+ inline
        # element; +named-content+ is the schema's designated carrier for
        # semantically named inline strings, and +content-type="identifier"+
        # records what the source element was. The element text is
        # preserved verbatim.
        class InlineIdentifierSanitizer
          CONTENT_TYPE = "identifier"

          class << self
            # @param doc [Nokogiri::XML::Document] the parsed STS document.
            # @return [Nokogiri::XML::Document] the same document.
            def apply(doc)
              doc.xpath("//p/identifier").each do |identifier|
                identifier.replace(named_content_for(identifier))
              end
              doc
            end

            private

            def named_content_for(identifier)
              doc = identifier.document
              node = Nokogiri::XML::Node.new("named-content", doc)
              node["content-type"] = CONTENT_TYPE
              identifier.children.each { |child| node << child }
              node
            end
          end
        end
      end
    end
  end
end
