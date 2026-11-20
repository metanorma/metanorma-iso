# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Decides whether a document is an amendment-style document from its
      # bibdata doctype. The classic converter ran these documents with
      # suppressed heading numbers and no table of contents
      # (metanorma-iso#1728).
      module AmendmentDoctype
        DOCTYPES = %w[amendment technical-corrigendum].freeze

        module_function

        def amendment?(model)
          ext = extension(model)
          return false unless attribute?(ext, :doctype_element)

          Array(ext.doctype_element).any? do |dt|
            DOCTYPES.include?(dt.value.to_s.strip.downcase)
          end
        end

        def extension(model)
          bib = model.bibdata if attribute?(model, :bibdata)
          bib.ext if attribute?(bib, :ext)
        end

        def attribute?(object, name)
          !object.nil? && object.class.attributes.key?(name)
        end
      end
    end
  end
end
