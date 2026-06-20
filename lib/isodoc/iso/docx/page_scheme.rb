# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Value object describing how a section's footer should be styled
      # and whether it carries a page-number field.
      #
      # The scheme is derived from the page numbering format declared on
      # the section's +sectPr/pageNumbering+ — a single source of truth
      # shared by SectionManager and HeaderFooterRenderer.
      class PageScheme
        ARABIC_FORMATS = %w[decimal].freeze
        ROMAN_FORMATS  = %w[lowerRoman upperRoman].freeze

        attr_reader :format

        # +format+ is the OOXML pgNumType value ("lowerRoman", "decimal",
        # nil). +page_number_field+ controls whether the footer carries
        # a page-number field (true for all numbered sections).
        def initialize(format:, page_number_field:)
          @format = format
          @page_number_field = page_number_field
        end

        def self.roman(page_number_field: true)
          new(format: "lowerRoman", page_number_field: page_number_field)
        end

        def self.arabic(page_number_field: true)
          new(format: "decimal", page_number_field: page_number_field)
        end

        def roman?
          ROMAN_FORMATS.include?(format.to_s)
        end

        def arabic?
          ARABIC_FORMATS.include?(format.to_s)
        end

        def page_number?
          @page_number_field
        end
      end
    end
  end
end
