# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_42: normative references must be ISO or IEC publications
        # (allowed otherwise only subject to ISO/IEC DIR 2 10.2 conditions).
        #
        # Walks every bibitem inside normative references sections and flags
        # any whose publisher is neither ISO nor IEC. Replaces the legacy
        # norm_bibitem_style which used Nokogiri XPath via
        # Metanorma::Iso::PublisherIdentity.
        class NormativeBibitemRule < Base
          code "ISO_42"

          ISO_ABBR = "ISO".freeze
          IEC_ABBR = "IEC".freeze
          ISO_NAME = "International Organization for Standardization".freeze
          IEC_NAME = "International Electrotechnical Commission".freeze

          def applicable?(context)
            !context.root.nil? && !context.root.bibliography.nil?
          end

          def check(context)
            issues = []
            each_normative_bibitem(context.root.bibliography) do |bibitem|
              next if iso_iec_publisher?(bibitem)

              issues << build_issue(location: bibitem_location(bibitem),
                                    params: [bibitem_text(bibitem)])
            end
            issues
          end

          private

          def each_normative_bibitem(bibliography)
            return enum_for(__method__, bibliography) unless block_given?

            Array(bibliography.references).each do |section|
              next unless normative?(section)
              Array(section.references).each { |bib| yield(bib) }
            end
          end

          def normative?(section)
            section.normative == true || section.normative.to_s == "true"
          end

          def iso_iec_publisher?(bibitem)
            publisher_orgs(bibitem).any? do |org|
              abbr = org.abbreviation.to_s
              name = organization_name(org)
              abbr == ISO_ABBR || abbr == IEC_ABBR ||
                name == ISO_NAME || name == IEC_NAME
            end
          end

          # Walks bibitem.contributor and selects organizations whose role
          # is "publisher". Mirrors PublisherIdentity::PUBLISHER XPath.
          def publisher_orgs(bibitem)
            Array(bibitem.contributor).each_with_object([]) do |c, orgs|
              next unless c.organization
              next unless contributor_is_publisher?(c)

              orgs << c.organization
            end
          end

          def contributor_is_publisher?(contributor)
            Array(contributor.role).any? { |role| role.type == "publisher" }
          end

          def organization_name(org)
            names = Array(org.name)
            return "" if names.empty?

            name = names.first
            return name.to_s unless name.is_a?(Lutaml::Model::Serializable)

            values = Array(name.value)
            values.empty? ? name.to_s : values.join
          rescue NoMethodError
            org.to_s
          end

          def bibitem_location(bibitem)
            id = bibitem_id(bibitem)
            id.nil? || id.to_s.empty? ? "bibitem" : "bibitem##{id}"
          end

          def bibitem_id(bibitem)
            bibitem.id if bibitem.class.method_defined?(:id)
          end

          def bibitem_text(bibitem)
            extract_text(bibitem).strip
          end
        end
      end
    end
  end
end
