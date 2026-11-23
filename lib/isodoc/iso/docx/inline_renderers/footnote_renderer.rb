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
            return if parent.heading_annotations_suppressed?
            return render_nested(element, para) if parent.in_footnote_body?

            handler = context.formula_key_footnote_handler
            return handler.call(element, para) if handler && !element.reference.to_s.strip.empty?

            cache_key = parent.footnote_cache_key(element)
            if cache_key && parent.cached_footnote_id(cache_key)
              append_cached_reference(para, cache_key)
              append_marker_suffix(element, para)
              return
            end

            text = parent.extract_footnote_text(element)
            return if (text.nil? || text.empty?) && !has_bare_link?(element)

            fn_run = parent.build_footnote_with_style(text, element: element)
            fn_id = fn_run.footnote_reference&.id
            parent.store_footnote_id(cache_key, fn_id) if cache_key && fn_id
            parent.apply_run_char_style(fn_run, :footnote_reference)
            para << fn_run
            append_marker_suffix(element, para)
          end

          private

          # ISO marks a body reference "1)", as the DOC output does. The
          # presentation XML carries the parenthesis in fmt-fn-label. The
          # mark in the footnote area stays a bare number, also as in DOC.
          def label_closing?(element)
            return false unless element.fmt_fn_label

            parent.collect_all_text(element.fmt_fn_label).rstrip.end_with?(")")
          end

          # Word supplies the number, so the parenthesis is its own run,
          # placed before the separator that follows the fn element.
          def append_marker_suffix(element, para)
            return unless label_closing?(element)

            properties = Uniword::Wordprocessingml::RunProperties.new(
              vertical_align: Uniword::Properties::VerticalAlign.new(value: "superscript"),
            )
            run = Uniword::Wordprocessingml::Run.new(text: ")", properties: properties)
            parent.apply_run_char_style(run, :footnote_reference)
            para << run
          end

          # Word cannot nest a footnote in a footnote body, so the inner
          # footnote's content is kept inline in the outer body.
          def render_nested(element, para)
            Array(element.p).each_with_index do |body, index|
              para << " " unless index.zero?
              parent.render(body, para)
            end
          end

          def has_bare_link?(element)
            element.p&.any? do |paragraph|
              Array(paragraph.link).any? { |link| !link.target.to_s.empty? }
            end
          end

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
