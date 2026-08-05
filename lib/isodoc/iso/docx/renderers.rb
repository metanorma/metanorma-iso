# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Per-content-type renderer classes. Each renderer handles one kind
      # of model node (Note, Figure, Table, etc.); the Renderers::Registry
      # maps model classes to renderer instances and dispatches nodes.
      module Renderers
        autoload :Base,                  "isodoc/iso/docx/renderers/base"
        autoload :Walker,                "isodoc/iso/docx/renderers/walker"
        autoload :Registry,              "isodoc/iso/docx/renderers/registry"
        autoload :NoteRenderer,          "isodoc/iso/docx/renderers/note_renderer"
        autoload :ExampleRenderer,       "isodoc/iso/docx/renderers/example_renderer"
        autoload :AdmonitionRenderer,    "isodoc/iso/docx/renderers/admonition_renderer"
        autoload :QuoteRenderer,         "isodoc/iso/docx/renderers/quote_renderer"
        autoload :DefinitionListRenderer,
                 "isodoc/iso/docx/renderers/definition_list_renderer"
        autoload :FigureRenderer,        "isodoc/iso/docx/renderers/figure_renderer"
        autoload :ParagraphRenderer,    "isodoc/iso/docx/renderers/paragraph_renderer"
        autoload :OrderedListRenderer,  "isodoc/iso/docx/renderers/ordered_list_renderer"
        autoload :UnorderedListRenderer,
                 "isodoc/iso/docx/renderers/unordered_list_renderer"
        autoload :TableRenderer,        "isodoc/iso/docx/renderers/table_renderer"
        autoload :TableAttachmentBuffer,
                 "isodoc/iso/docx/renderers/table_attachment_buffer"
        autoload :TableCellElement,    "isodoc/iso/docx/renderers/table_cell_element"
        autoload :ImageRenderer,        "isodoc/iso/docx/renderers/image_renderer"
        autoload :SectionRenderer,      "isodoc/iso/docx/renderers/section_renderer"
        autoload :ClauseRenderer,       "isodoc/iso/docx/renderers/clause_renderer"
        autoload :AnnexRenderer,        "isodoc/iso/docx/renderers/annex_renderer"
        autoload :TermsSectionRenderer, "isodoc/iso/docx/renderers/terms_section_renderer"
        autoload :TermRenderer,         "isodoc/iso/docx/renderers/term_renderer"
        autoload :BibliographyRenderer, "isodoc/iso/docx/renderers/bibliography_renderer"
        autoload :ReferencesRenderer, "isodoc/iso/docx/renderers/references_renderer"
        autoload :AmendRenderer,        "isodoc/iso/docx/renderers/amend_renderer"
        autoload :PageBreakRenderer,   "isodoc/iso/docx/renderers/page_break_renderer"
        autoload :HorizontalRuleRenderer,
                 "isodoc/iso/docx/renderers/horizontal_rule_renderer"
        autoload :NullRenderer,        "isodoc/iso/docx/renderers/null_renderer"
      end
    end
  end
end
