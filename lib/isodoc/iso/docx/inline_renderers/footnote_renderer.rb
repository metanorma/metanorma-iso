# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <fn> as a Word footnote reference run. The footnote
        # body paragraph carries the FootnoteText style (Era C).
        #
        # Identical footnotes are COLLAPSED: when an <fn>'s cache key
        # (target or id) matches one already rendered, the renderer
        # reuses the existing footnote id instead of creating a new
        # footnote. This keeps the footnotes pane clean — the rice
        # document has 22 <fn> elements but only 16 distinct footnotes.
        class FootnoteRenderer
          include Base

          def render(element, para)
            cache_key = parent.footnote_cache_key(element)
            if cache_key && parent.cached_footnote_id(cache_key)
              append_cached_reference(para, cache_key)
              return
            end

            text = parent.extract_footnote_text(element)
            return if text.nil? || text.empty?

            fn_run = parent.build_footnote_with_style(text)
            fn_id = fn_run.footnote_reference&.id
            parent.store_footnote_id(cache_key, fn_id) if cache_key && fn_id
            parent.apply_run_char_style(fn_run, :footnote_reference)
            para << fn_run
          end

          private

          def append_cached_reference(para, cache_key)
            id = parent.cached_footnote_id(cache_key)
            fn_run = Uniword::Wordprocessingml::Run.new(
              footnote_reference: Uniword::Wordprocessingml::FootnoteReference.new(id: id.to_s),
            )
            parent.apply_run_char_style(fn_run, :footnote_reference)
            para << fn_run
          end
        end
      end
    end
  end
end
