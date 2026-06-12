# frozen_string_literal: true

module IsoDoc
  module Iso
    # Tight coupling to Docx module — autoload from parent namespace.
    autoload :DocxStyleMapping, "isodoc/iso/docx_style_mapping"
    autoload :DocxTemplates, "isodoc/iso/docx_style_mapping"

    # ISO DOCX generation via Uniword.
    #
    # Architecture:
    #   metanorma-document model → Adapter → Uniword builders → DOCX/MHTML
    #
    # The Adapter orchestrates a team of renderer objects, each responsible
    # for one concern (cover page, boilerplate, sections, TOC, etc.).
    # Style resolution is delegated to StyleResolver; inline element
    # rendering to InlineRenderer.
    #
    # New document sections are added by extending the adapter's visit_root
    # flow. New element types are handled by extending visit_block.
    # New styles are added to style_mapping.yml (OCP).
    module Docx
      autoload :Adapter, "isodoc/iso/docx/adapter"
      autoload :BoilerplateRenderer, "isodoc/iso/docx/boilerplate_renderer"
      autoload :CommentRenderer, "isodoc/iso/docx/comment_renderer"
      autoload :Context, "isodoc/iso/docx/context"
      autoload :Counter, "isodoc/iso/docx/context"
      autoload :CoverRenderer, "isodoc/iso/docx/cover_renderer"
      autoload :DocumentProperties, "isodoc/iso/docx/document_properties"
      autoload :FormulaRenderer, "isodoc/iso/docx/formula_renderer"
      autoload :InlineRenderer, "isodoc/iso/docx/inline"
      autoload :ModelUtils, "isodoc/iso/docx/model_utils"
      autoload :SectionManager, "isodoc/iso/docx/section_manager"
      autoload :StyleResolver, "isodoc/iso/docx/style_resolver"
      autoload :TocBuilder, "isodoc/iso/docx/toc_builder"
    end
  end
end
