# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module OutputSanitizer
        # Repairs +<std-meta>+ after mnconvert splices its "unprocessed
        # elements in bibdata" diagnostic into the front: the warning is
        # emitted as bare character content (the XSD declares std-meta
        # element-only) wrapped around the leaked elements themselves.
        #
        # Stray character content is removed; leaked elements — flavor
        # build attributes such as +<iso-cen-parallel>+ that have no NISO
        # STS counterpart — are preserved as
        # +<custom-meta-group>/<custom-meta>+ entries, the construct NISO
        # STS defines exactly for out-of-band metadata.
        class FrontLeakSanitizer
          # Element children allowed by the std-meta-model group of the
          # NISO STS extended-1 MathML3 XSD. Anything else found under
          # +<std-meta>+ is Metanorma-internal and migrates to
          # custom-meta.
          ALLOWED_CHILDREN = %w[
            title-wrap proj-id release-version std-ident std-org
            std-org-group content-language std-ref doc-ref pub-date
            release-date meta-date wi-number comm-ref comm-ref-group
            accrediting-organization authorization secretariat ics ics-wrap
            subj-group page-count counts is-proof std-xref
            release-version-id permissions self-uri abstract kwd-group
            meta-note custom-meta-group
          ].freeze

          class << self
            # @param doc [Nokogiri::XML::Document] the parsed STS document.
            # @return [Nokogiri::XML::Document] the same document.
            def apply(doc)
              doc.xpath("//std-meta").each do |std_meta|
                migrate_leaked_elements(std_meta)
                remove_stray_text(std_meta)
              end
              doc
            end

            private

            def migrate_leaked_elements(std_meta)
              leaked = std_meta.element_children
                .reject { |element| ALLOWED_CHILDREN.include?(element.name) }
              return if leaked.empty?

              group = std_meta.xpath("custom-meta-group").last ||
                create_custom_meta_group(std_meta)
              leaked.each do |element|
                group << custom_meta_for(element)
                element.remove
              end
            end

            # custom-meta-group is the final position of the std-meta
            # sequence, so a created group is appended, never inserted.
            def create_custom_meta_group(std_meta)
              group = Nokogiri::XML::Node.new("custom-meta-group",
                                              std_meta.document)
              std_meta << group
              group
            end

            def custom_meta_for(element)
              doc = element.document
              meta = Nokogiri::XML::Node.new("custom-meta", doc)
              name = Nokogiri::XML::Node.new("meta-name", doc)
              name.content = element.name
              value = Nokogiri::XML::Node.new("meta-value", doc)
              value.content = element.text.strip
              meta << name
              meta << value
              meta
            end

            # Only bare text is illegal in std-meta; whitespace between
            # elements stays untouched.
            def remove_stray_text(std_meta)
              std_meta.xpath("./text()[normalize-space() != '']").each(&:remove)
            end
          end
        end
      end
    end
  end
end
