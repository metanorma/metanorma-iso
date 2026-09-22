# frozen_string_literal: true

require "pathname"
require "set"

module IsoDoc
  module Iso
    module Docx
      # Compares a generated DOCX's used styleIds against a StyleLibrary
      # and a list of excluded (pollution) styleIds. End-to-end spec
      # uses this to catch Era-C-incompatible style references.
      class StyleIdAsserter
        def initialize(xml, library:, excluded: [])
          @xml = xml
          @library = library
          @excluded = excluded.to_set
        end

        def used_style_ids
          return [] unless @xml

          @xml.xpath("//*[local-name()='pStyle' or local-name()='rStyle']")
              .map { |e| e["w:val"] || e["val"] }
              .compact
              .uniq
        end

        def unknown_style_ids
          known = @library.all_style_ids.to_set
          used_style_ids.reject { |id| known.include?(id.to_s) }
        end

        def pollution_style_ids
          (used_style_ids & @excluded.to_a)
        end
      end
    end
  end
end
