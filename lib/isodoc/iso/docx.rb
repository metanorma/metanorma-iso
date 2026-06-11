# frozen_string_literal: true

module IsoDoc
  module Iso
    # Tight coupling to Docx module — autoload from parent namespace.
    autoload :DocxStyleMapping, "isodoc/iso/docx_style_mapping"
    autoload :DocxTemplates, "isodoc/iso/docx_style_mapping"

    # ISO DOCX generation via Uniword.
    #
    # Configuration-only: all visual styles come from the DOCX template
    # (data/iso-dis/ or data/iso-simple/). This module maps metanorma-document
    # model elements to the correct template styles via DocxStyleMapping.
    module Docx
      autoload :Adapter, "isodoc/iso/docx/adapter"
      autoload :Context, "isodoc/iso/docx/context"
      autoload :Counter, "isodoc/iso/docx/context"
      autoload :DocumentProperties, "isodoc/iso/docx/document_properties"
      autoload :InlineRenderer, "isodoc/iso/docx/inline"
      autoload :ModelUtils, "isodoc/iso/docx/model_utils"
      autoload :StyleResolver, "isodoc/iso/docx/style_resolver"
    end
  end
end
