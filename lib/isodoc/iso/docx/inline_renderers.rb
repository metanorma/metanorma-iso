# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Per-element-type inline renderer classes. Each handler renders
      # one kind of model element (italic, link, footnote, etc.) into a
      # ParagraphBuilder. The InlineRenderers::Registry maps model
      # classes to handler instances and dispatches elements.
      #
      # Adding a new inline type = new handler class + one +register+
      # call in Registry#register_defaults — no edit to existing
      # dispatch logic (Open/Closed Principle).
      module InlineRenderers
        autoload :Base, "isodoc/iso/docx/inline_renderers/base"
        autoload :Registry, "isodoc/iso/docx/inline_renderers/registry"
        autoload :ItalicRenderer, "isodoc/iso/docx/inline_renderers/italic_renderer"
        autoload :BoldRenderer, "isodoc/iso/docx/inline_renderers/bold_renderer"
        autoload :SubscriptRenderer, "isodoc/iso/docx/inline_renderers/subscript_renderer"
        autoload :SuperscriptRenderer, "isodoc/iso/docx/inline_renderers/superscript_renderer"
        autoload :MonospaceRenderer, "isodoc/iso/docx/inline_renderers/monospace_renderer"
        autoload :StrikethroughRenderer,
                 "isodoc/iso/docx/inline_renderers/strikethrough_renderer"
        autoload :UnderlineRenderer, "isodoc/iso/docx/inline_renderers/underline_renderer"
        autoload :KeywordRenderer, "isodoc/iso/docx/inline_renderers/keyword_renderer"
        autoload :SmallCapRenderer, "isodoc/iso/docx/inline_renderers/smallcap_renderer"
        autoload :BreakRenderer, "isodoc/iso/docx/inline_renderers/break_renderer"
        autoload :TabRenderer, "isodoc/iso/docx/inline_renderers/tab_renderer"
        autoload :PageBreakRenderer,
                 "isodoc/iso/docx/inline_renderers/page_break_renderer"
        autoload :LinkRenderer, "isodoc/iso/docx/inline_renderers/link_renderer"
        autoload :XrefRenderer, "isodoc/iso/docx/inline_renderers/xref_renderer"
        autoload :ErefRenderer, "isodoc/iso/docx/inline_renderers/eref_renderer"
        autoload :FmtXrefRenderer, "isodoc/iso/docx/inline_renderers/fmt_xref_renderer"
        autoload :FootnoteRenderer, "isodoc/iso/docx/inline_renderers/footnote_renderer"
        autoload :CalloutRenderer, "isodoc/iso/docx/inline_renderers/callout_renderer"
        autoload :AnnotationStartRenderer,
                 "isodoc/iso/docx/inline_renderers/annotation_start_renderer"
        autoload :AnnotationEndRenderer,
                 "isodoc/iso/docx/inline_renderers/annotation_end_renderer"
        autoload :StemRenderer, "isodoc/iso/docx/inline_renderers/stem_renderer"
        autoload :AsciimathRenderer,
                 "isodoc/iso/docx/inline_renderers/asciimath_renderer"
        autoload :ImageRenderer, "isodoc/iso/docx/inline_renderers/image_renderer"
        autoload :BookmarkRenderer,
                 "isodoc/iso/docx/inline_renderers/bookmark_renderer"
        autoload :Bcp14Renderer, "isodoc/iso/docx/inline_renderers/bcp14_renderer"
        autoload :SpanRenderer, "isodoc/iso/docx/inline_renderers/span_renderer"
        autoload :SemxRenderer, "isodoc/iso/docx/inline_renderers/semx_renderer"
        autoload :MixedInlineFallbackRenderer,
                 "isodoc/iso/docx/inline_renderers/mixed_inline_fallback_renderer"
        autoload :TermExpressionRenderer,
                 "isodoc/iso/docx/inline_renderers/term_expression_renderer"
        autoload :TermNameRenderer,
                 "isodoc/iso/docx/inline_renderers/term_name_renderer"
        autoload :NullRenderer, "isodoc/iso/docx/inline_renderers/null_renderer"
      end
    end
  end
end
