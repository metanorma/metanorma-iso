# frozen_string_literal: true

require "metanorma/html"

module Metanorma
  module Iso
    # HTML format adapter slice for the ISO flavor: the renderer plus
    # the flavor-owned variant resolver (publisher-based dispatch).
    module Html
      autoload :Renderer, "#{__dir__}/html/renderer"

      class << self
        # First author-publisher abbreviation on the document's bibdata,
        # or nil. Drives variant renderer selection (e.g. ICC).
        def publisher_abbreviation(document)
          bibdata = document.bibdata if document.is_a?(Lutaml::Model::Serializable)
          return nil unless bibdata

          contributors = bibdata.contributor
          return nil unless contributors

          contributors.each do |c|
            roles = c.role
            next unless roles.is_a?(Array)
            next unless roles.any? { |r| r&.type == "author" }

            org = c.organization
            next unless org

            abbrev = organization_abbreviation(org)
            return abbrev if abbrev
          end
          nil
        end

        private

        def organization_abbreviation(org)
          abbrev = org.abbreviation
          case abbrev
          when String then abbrev
          when Lutaml::Model::Serializable
            attr = abbrev.class.attributes.key?(:content) ? :content : nil
            attr && abbrev.public_send(attr)
          else abbrev.to_s unless abbrev.nil?
          end
        end
      end
    end
  end
end
