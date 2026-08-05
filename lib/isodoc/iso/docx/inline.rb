# frozen_string_literal: true

require "uniword"
require "metanorma/document"

module IsoDoc
  module Iso
    module Docx
      # Renders inline model elements to Uniword Run objects via a
      # team of InlineRenderers handler classes.
      #
      # The InlineRenderer owns shared state (resolver, context, doc
      # builder, footnote cache, autonum-stripping flag) and shared
      # utilities (add_text, render_with_run_format, hyperlink styling,
      # etc.). Each kind of inline element (italic, link, footnote, …)
      # has a dedicated handler class under InlineRenderers::*; the
      # InlineRenderers::Registry maps model classes to handlers.
      #
      # Adding a new inline type = new handler class + one +register+
      # call in InlineRenderers::Registry#register_defaults — no edit
      # to InlineRenderer itself (Open/Closed Principle).
      class InlineRenderer
        include ModelUtils

        # Public state: handlers and SourcecodeRenderer read/write these.
        attr_accessor :preserve_whitespace
        attr_reader :resolver, :context, :doc, :footnote_cache

        # Callable that maps annotation target IDs to DOCX comment IDs.
        # Set by the adapter after creating the CommentRenderer.
        attr_writer :comment_id_lookup

        def initialize(context, resolver, doc_builder)
          @context = context
          @resolver = resolver
          @doc = doc_builder
          @footnote_cache = {}
          @preserve_whitespace = false
          @comment_id_lookup = nil
          @strip_autonum = false
          @registry = InlineRenderers::Registry.new(self)
        end

        # Render all inline content from a node into a ParagraphBuilder.
        def render(node, para)
          if ordered?(node)
            render_ordered_inline(node, para)
          else
            render_collection_inline(node, para)
          end
        end

        # Render inline content for headings, skipping auto-number carriers
        # so the style's numPr produces the section number alone — but
        # ONLY when the paragraph's style actually has numPr. Styles that
        # emit the number as visible text (e.g. TermNum) keep autonum.
        #
        # Skipped when stripping is active:
        #   - <span class="fmt-caption-delim"> (the tab between number and title)
        #   - <span class="fmt-caption-label"> (wraps the autonum text)
        #   - <semx element="autonum">         (carries the autonum text)
        #
        # Stripping applies recursively — autonum carriers wrapped inside
        # other inline elements (e.g. <strong>) are also skipped.
        def render_heading(node, para)
          unless strip_autonum_for?(para)
            render(node, para)
            return
          end

          was_stripping = @strip_autonum
          @strip_autonum = true
          begin
            if ordered?(node)
              render_heading_ordered(node, para)
            else
              render(node, para)
            end
          ensure
            @strip_autonum = was_stripping
          end
        end

        # Whether autonum carriers should be stripped for this paragraph.
        # True only when the paragraph's style is in the template's
        # auto-numbered set (Heading1-6, ANNEX, a2-a6, ...).
        def strip_autonum_for?(para)
          style = para.style
          return false unless style

          @resolver.auto_numbered_style?(style.value)
        end

        # Whether the renderer is currently stripping autonum carriers
        # (i.e., inside a heading render where the paragraph style
        # carries numPr). Handlers consult this to skip autonum content.
        def stripping_autonum?
          @strip_autonum
        end

        # Whether a heading's body is empty after autonum carriers are
        # stripped. Untitled sub-clauses have <fmt-title> with only the
        # section number + delimiter — they should skip the heading
        # paragraph entirely so the body paragraph follows directly.
        def heading_body_empty?(node)
          text = collect_heading_body_text(node)
          text.nil? || text.strip.empty?
        end

        # Add a text run to the paragraph, normalizing whitespace unless
        # `preserve_whitespace` is set (used by SourcecodeRenderer).
        #
        # Newlines inside source XML text nodes (e.g. between </fn> and
        # the trailing ", " inside <biblio-tag>) MUST be collapsed to a
        # single space here — otherwise the DOCX serializer converts
        # them to <w:br/> runs, breaking bibliography entries across
        # lines. Leading/trailing whitespace is preserved because it
        # carries inter-word spacing between sibling elements (e.g. the
        # " " between <span>ISO</span> and <span>712</span>).
        def add_text(para, text)
          return if text.nil?

          if @preserve_whitespace
            add_preserved_text(para, text.to_s)
          else
            normalized = text.to_s.gsub(/[ \t\r\n]+/, " ")
            para << normalized unless normalized.empty?
          end
        end

        # ── Shared utilities (used by InlineRenderers handlers) ───────

        # Dispatch an inline element to its registered handler. Falls
        # back to text collection when no handler matches.
        def dispatch_inline(element, para)
          @registry.dispatch(element, para)
        end

        # Fallback for elements with no registered handler: collect text
        # and append it. InlineRenderers::Registry calls this when no
        # ancestor of the element's class is registered.
        def render_unmatched_element(element, para)
          text = collect_text(element)
          add_text(para, text) if text && !text.empty?
        end

        # Add text with a character style (rStyle) applied.
        def add_text_with_char_style(para, text, style_key)
          style = style_key.is_a?(String) ? style_key : @resolver.character_style(style_key)

          if style
            run = Uniword::Wordprocessingml::Run.new(text: text.to_s)
            run.properties = Uniword::Wordprocessingml::RunProperties.new(
              style: Uniword::Properties::RunStyleReference.new(value: style),
            )
            para << run
          else
            add_text(para, text)
          end
        end

        # Apply a character style from the resolver by key name.
        def apply_run_char_style(run, style_key)
          style = @resolver.character_style(style_key)
          return unless style

          run.properties ||= Uniword::Wordprocessingml::RunProperties.new
          run.properties.style = Uniword::Properties::RunStyleReference.new(
            value: style,
          )
        end

        # Apply the Hyperlink character style to every run in a hyperlink.
        def apply_hyperlink_style(hyperlink_model)
          style = @resolver.character_style(:hyperlink)
          return unless style

          hyperlink_model.runs.each do |run|
            run.properties ||= Uniword::Wordprocessingml::RunProperties.new
            run.properties.style = Uniword::Properties::RunStyleReference.new(
              value: style,
            )
          end
        end

        # Walk an element's mixed-content children in document order,
        # dispatching each child through +#dispatch_inline+. Used by
        # handlers that need to recurse (SpanRenderer, SemxRenderer,
        # MixedInlineFallbackRenderer, FmtXrefRenderer).
        def render_mixed_inline_fallback(element, para)
          if ordered?(element)
            element.each_mixed_content do |child|
              case child
              when String then add_text(para, child)
              else dispatch_inline(child, para)
              end
            end
          else
            text = collect_text(element)
            add_text(para, text) if text && !text.empty?
          end
        end

        # Render an element's content into a temporary paragraph, then
        # apply +formatter+ to each produced run before appending it to
        # +para+. Used by run-formatting handlers (italic, bold, sub,
        # sup) to apply their format to nested rich content.
        def render_with_run_format(element, para)
          temp = Uniword::Builder::ParagraphBuilder.new
          render_mixed_inline_fallback(element, temp)
          temp.model.runs.each do |run|
            run.properties ||= Uniword::Wordprocessingml::RunProperties.new
            yield run
            para << run
          end
          temp.model.hyperlinks.each do |link|
            link.runs.each do |run|
              run.properties ||= Uniword::Wordprocessingml::RunProperties.new
              yield run
            end
            para << link
          end
        end

        # Render a SpanElement's content with a character style applied.
        def render_with_char_style(element, para, style)
          if ordered?(element)
            element.each_mixed_content do |child|
              case child
              when String
                next if child.nil? || child.empty?

                add_text_with_char_style(para, child, style)
              else
                dispatch_inline(child, para)
              end
            end
          else
            text = collect_text(element)
            if text && !text.empty?
              add_text_with_char_style(para, text, style)
            end
          end
        end

        # Whether an element has element_order children that are not
        # just text nodes (i.e., rich content requiring recursive format).
        def has_rich_children?(element)
          eo = element.element_order
          return false unless eo.is_a?(Array) && !eo.empty?

          eo.any? { |e| e.element? && e.name != "text" }
        end

        # When bolding a run that already carries the InlineCode character
        # style, promote it to InlineCodeBold (Era C's dedicated style for
        # bold inline code). For every other run, apply a direct bold run
        # property as before.
        def apply_bold_to_run(run)
          code_style = @resolver.character_style(:inline_code)
          bold_code_style = @resolver.character_style(:inline_code_bold)
          current_style = run.properties&.style&.value

          if code_style && current_style == code_style && bold_code_style
            run.properties.style = Uniword::Properties::RunStyleReference.new(
              value: bold_code_style,
            )
          else
            run.properties.bold = Uniword::Properties::Bold.new
          end
        end

        # Whether an element carries auto-number content that the heading
        # style's numPr will render on its own. Such elements must be
        # skipped to avoid the number appearing twice.
        def autonum_carrier?(element)
          return false unless element.is_a?(Lutaml::Model::Serializable)

          if element.is_a?(Metanorma::Document::Components::Inline::SemxElement)
            return element.element_attr.to_s == "autonum"
          end

          return false unless element.is_a?(Metanorma::Document::Components::Inline::SpanElement)

          cls = element.class_attr
          return true if cls == "fmt-caption-delim"
          return true if cls == "fmt-caption-label"
          return true if cls == "fmt-element-name"

          false
        end

        # ── Stem / footnote / callout helpers ─────────────────────────

        def stem_fallback_text(element)
          if element.class.attributes.key?(:asciimath)
            am = element.asciimath
            return am if am.is_a?(String) && !am.empty?
          end
          collect_text(element)
        end

        def collect_callout_text(callout)
          segments = []
          each_ordered_element(callout) do |type, obj|
            segments << obj.to_s if type == :text
          end
          segments.join
        end

        # Cache key is the source footnote identity (target → id → reference),
        # NOT the text. Two footnotes with the same text but different source
        # identities are distinct footnotes in OOXML.
        def footnote_cache_key(element)
          return element.target if element.class.attributes.key?(:target) && element.target
          return element.id if element.class.attributes.key?(:id) && element.id

          nil
        end

        def cached_footnote_id(cache_key)
          @footnote_cache[cache_key]
        end

        def store_footnote_id(cache_key, id)
          @footnote_cache[cache_key] = id
        end

        def extract_footnote_text(element)
          p_children = element.p
          if p_children && !p_children.empty?
            return p_children.map { |p| collect_text(p) }.join(" ")
          end

          collect_all_text(element)
        end

        # Create a footnote whose body paragraph carries the
        # FootnoteText style, so the body text matches the Era C
        # template's footnote typography rather than the document
        # default.
        def build_footnote_with_style(text)
          style = @resolver.paragraph_style(:footnote_text)
          @doc.footnote do |p|
            p.style = style if style
            p << text
          end
        end

        def lookup_comment_id(annotation_target_id)
          return nil unless @comment_id_lookup

          @comment_id_lookup.call(annotation_target_id)
        end

        private

        # ── Ordered-content walking ───────────────────────────────────

        def render_ordered_inline(node, para)
          walked = false
          each_ordered_element(node) do |type, obj|
            walked = true
            case type
            when :text then add_text(para, obj)
            when :element then dispatch_inline(obj, para)
            end
          end
          return if walked

          node.each_mixed_content do |child|
            case child when String then add_text(para, child)
            else dispatch_inline(child, para)
            end
          end
        end

        # Fallback: render typed attribute collections when no ordering
        # information is available.
        def render_collection_inline(node, para)
          texts = extract_texts(node)
          texts.each { |t| add_text(para, t) unless t.nil? || t.empty? }

          render_inline_elements(node, para)
        end

        def render_inline_elements(node, para)
          return unless node.is_a?(Lutaml::Model::Serializable)

          inline_attrs = %i[em strong sub sup tt underline strike keyword
                            smallcap xref eref link fn fmt_stem bookmark
                            image br span concept bcp14]
          inline_attrs.each do |attr|
            next unless node.class.attributes.key?(attr)

            val = node.public_send(attr)
            next if val.nil?

            Array(val).each { |el| dispatch_inline(el, para) }
          end
        end

        # Split text on newlines and insert <w:br/> runs between lines.
        # This is essential for sourcecode blocks where newlines must be
        # preserved as line breaks in the DOCX output.
        def add_preserved_text(para, text)
          return if text.empty?

          lines = text.split("\n", -1)
          lines.each_with_index do |line, i|
            unless i.zero?
              br_run = Uniword::Wordprocessingml::Run.new
              br_run.break = Uniword::Wordprocessingml::Break.new
              para << br_run
            end
            para << line unless line.empty?
          end
        end

        # ── Heading rendering (autonum stripping) ─────────────────────

        def render_heading_ordered(node, para)
          walked = false
          each_ordered_element(node) do |type, obj|
            walked = true
            walk_heading_child(type, obj, para)
          end
          return if walked

          render(node, para)
        end

        def walk_heading_child(type, obj, para)
          case type
          when :text then para << obj
          when :element
            return if autonum_carrier?(obj)

            dispatch_inline(obj, para)
          end
        end

        # Collect body text from a heading, skipping autonum carriers.
        # Returns "" if the heading has no body text (only autonum + delim).
        def collect_heading_body_text(node)
          return node.to_s unless node.is_a?(Lutaml::Model::Serializable)
          return collect_text(node) unless ordered?(node)

          collect_ordered_body_text(node)
        end

        def collect_ordered_body_text(node)
          segments = []
          each_ordered_element(node) do |type, obj|
            case type
            when :text then segments << obj.to_s
            when :element
              next if autonum_carrier?(obj)

              segments << collect_text(obj).to_s
            end
          end
          segments.join
        end
      end
    end
  end
end
