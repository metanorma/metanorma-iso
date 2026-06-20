# frozen_string_literal: true

require "uniword"
require "metanorma/document"

module IsoDoc
  module Iso
    module Docx
      # Renders inline model elements to Uniword Run objects.
      #
      # Handles mixed-content inline elements (text, em, strong, sub, sup,
      # links, footnotes, math, images) preserving document order via
      # element_order or each_mixed_content.
      #
      # Character styles (rStyles) are applied contextually:
      #   - Hyperlink rStyle on all hyperlink runs
      #   - FootnoteReference rStyle on footnote reference runs
      #   - Span class → character style mapping via StyleResolver
      class InlineRenderer
        include ModelUtils

        attr_accessor :preserve_whitespace

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
        end

        # Render all inline content from a node into a ParagraphBuilder.
        def render(node, para)
          if ordered?(node)
            render_ordered_inline(node, para)
          else
            render_collection_inline(node, para)
          end
        end

        def render_ordered_inline(node, para)
          walked = false
          each_ordered_element(node) do |type, obj|
            walked = true
            case type
            when :text then add_text(para, obj)
            when :element then render_inline_element(obj, para)
            end
          end
          return if walked

          node.each_mixed_content do |child|
            case child when String then add_text(para, child)
            else render_inline_element(child, para)
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

        # Central inline dispatch — MECE by design.
        #
        # Subclass types MUST appear before their superclass in the
        # case/when to avoid the superclass branch matching first.
        def render_inline_element(element, para)
          case element
          when Metanorma::Document::Components::Inline::EmRawElement,
               Metanorma::Document::Components::TextElements::EmphasisElement
            render_italic(element, para)
          when Metanorma::Document::Components::Inline::StrongRawElement,
               Metanorma::Document::Components::TextElements::StrongElement
            render_bold(element, para)
          when Metanorma::Document::Components::Inline::SubElement,
               Metanorma::Document::Components::TextElements::SubscriptElement
            render_subscript(element, para)
          when Metanorma::Document::Components::Inline::SupElement,
               Metanorma::Document::Components::TextElements::SuperscriptElement
            render_superscript(element, para)
          when Metanorma::Document::Components::Inline::TtElement,
               Metanorma::Document::Components::TextElements::MonospaceElement
            render_monospace(element, para)
          when Metanorma::Document::Components::TextElements::StrikeElement
            render_strikethrough(element, para)
          when Metanorma::Document::Components::TextElements::UnderlineElement
            render_underline(element, para)
          when Metanorma::Document::Components::TextElements::KeywordElement
            render_keyword(element, para)
          when Metanorma::Document::Components::TextElements::SmallCapsElement,
               Metanorma::Document::Components::Inline::SmallCapElement
            render_smallcap(element, para)
          when Metanorma::Document::Components::Inline::BrElement
            br_run = Uniword::Wordprocessingml::Run.new
            br_run.break = Uniword::Wordprocessingml::Break.new
            para << br_run
          when Metanorma::Document::Components::Inline::TabElement
            tab_run = Uniword::Wordprocessingml::Run.new
            tab_run.tab = Uniword::Wordprocessingml::Tab.new
            para << tab_run
          when Metanorma::Document::Components::EmptyElements::PageBreakElement
            para << Uniword::Builder.page_break
          when Metanorma::Document::Components::Inline::LinkElement
            render_link(element, para)
          when Metanorma::Document::Components::Inline::XrefElement
            render_xref(element, para)
          when Metanorma::Document::Components::Inline::ErefElement
            render_eref(element, para)
          when Metanorma::Document::Components::Inline::FnElement
            render_footnote(element, para)
          when Metanorma::Document::Components::ReferenceElements::Callout
            render_callout(element, para)
          when Metanorma::Document::Components::Inline::FmtStemElement,
               Metanorma::Document::Components::Inline::StemInlineElement,
               Metanorma::Document::Components::TextElements::StemElement
            render_stem(element, para)
          when Metanorma::Document::Components::Inline::MathElement
            # Skip — math is handled by render_stem on the parent stem element
          when Metanorma::Document::Components::Inline::AsciimathElement
            text = element.text if element.class.attributes.key?(:text)
            add_text_with_char_style(para, text, :stem) if text.is_a?(String) && !text.empty?
          when Metanorma::Document::Components::IdElements::Image
            render_inline_image(element, para)
          when Metanorma::Document::Components::IdElements::Bookmark
            render_bookmark(element, para)
          when Metanorma::Document::Components::Inline::Bcp14Element
            render_bold(collect_text(element), para)
          when Metanorma::Document::Components::Inline::SpanElement
            render_span(element, para)
          when Metanorma::Document::Components::Inline::SemxElement
            render_semx(element, para)
          when Metanorma::Document::Components::Paragraphs::ParagraphBlock
            render_mixed_inline_fallback(element, para)
          when Metanorma::Document::Components::Inline::FmtXrefElement
            render_fmt_xref(element, para)
          when Metanorma::Document::Components::Inline::FmtXrefLabelElement
            nil
          when Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
               Metanorma::Document::Components::Inline::FmtFnLabelElement,
               Metanorma::Document::Components::Inline::FmtAnnotationStartElement
            render_annotation_start(element, para)
          when Metanorma::Document::Components::Inline::FmtAnnotationEndElement
            render_annotation_end(element, para)
          when Metanorma::Document::Components::Inline::FmtTitleElement,
               Metanorma::Document::Components::Inline::FmtNameElement
            render_mixed_inline_fallback(element, para)
          when Metanorma::IsoDocument::Terms::TermExpression
            Array(element.name).each { |n| render(n, para) }
          when Metanorma::IsoDocument::Terms::TermNameElement
            render(element, para)
          when Metanorma::Document::Components::Inline::VariantTitleElement
            render_mixed_inline_fallback(element, para)
          else
            text = collect_text(element)
            add_text(para, text) if text && !text.empty?
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
        def add_text(para, text)
          return if text.nil?

          if @preserve_whitespace
            add_preserved_text(para, text.to_s)
          else
            normalized = text.to_s.gsub(/[ \t]+/, " ")
            para << normalized unless normalized.empty?
          end
        end

        private

        def render_heading_ordered(node, para)
          walked = false
          each_ordered_element(node) do |type, obj|
            walked = true
            case type
            when :text then para << obj
            when :element
              next if autonum_carrier?(obj)
              render_inline_element(obj, para)
            end
          end
          return if walked

          render(node, para)
        end

        # Collect body text from a heading, skipping autonum carriers.
        # Returns "" if the heading has no body text (only autonum + delim).
        def collect_heading_body_text(node)
          return node.to_s unless node.is_a?(Lutaml::Model::Serializable)
          return collect_text(node) unless ordered?(node)

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

        # Whether an element carries auto-number content that the heading
        # style's numPr will render on its own. Such elements must be
        # skipped to avoid the number appearing twice.
        #
        # Recognized carriers (at any nesting depth in heading mode):
        #   - <span class="fmt-caption-delim">
        #   - <span class="fmt-caption-label">
        #   - <span class="fmt-element-name">  (e.g. "Annex", "Clause")
        #   - <semx element="autonum">         (carries the autonum text)
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

        # SpanElement with a class attribute maps to a DOCX character style.
        # Presentation XML uses spans like <span class="stdpublisher">ISO</span>
        # where the class value IS the DOCX character styleId.
        #
        # When stripping autonum (heading mode), skip spans whose class
        # marks them as autonum carriers — at any nesting depth.
        def render_span(element, para)
          return if @strip_autonum && autonum_carrier?(element)

          style = @resolver.span_class_style(element.class_attr)
          if style
            render_with_char_style(element, para, style)
          else
            render_mixed_inline_fallback(element, para)
          end
        end

        def render_with_char_style(element, para, style)
          if ordered?(element)
            element.each_mixed_content do |child|
              case child
              when String
                next if child.nil? || child.empty?

                add_text_with_char_style(para, child, style)
              else
                render_inline_element(child, para)
              end
            end
          else
            text = collect_text(element)
            if text && !text.empty?
              add_text_with_char_style(para, text, style)
            end
          end
        end

        def render_italic(element, para)
          if element.is_a?(String)
            text = element
          elsif ordered?(element) && has_rich_children?(element)
            render_with_run_format(element, para) { |run| run.properties.italic = Uniword::Properties::Italic.new }
            return
          else
            text = collect_text(element)
          end
          return if text.nil? || text.to_s.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text.to_s).italic
          para << run.build
        end

        def render_bold(element, para)
          if element.is_a?(String)
            text = element
          elsif ordered?(element) && has_rich_children?(element)
            render_with_run_format(element, para) { |run| apply_bold_to_run(run) }
            return
          else
            text = collect_text(element)
          end
          return if text.nil? || text.to_s.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text.to_s).bold
          para << run.build
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

        def render_with_run_format(element, para, &formatter)
          temp = Uniword::Builder::ParagraphBuilder.new
          render_mixed_inline_fallback(element, temp)
          temp.model.runs.each do |run|
            run.properties ||= Uniword::Wordprocessingml::RunProperties.new
            formatter.call(run)
            para << run
          end
          temp.model.hyperlinks.each do |link|
            link.runs.each do |run|
              run.properties ||= Uniword::Wordprocessingml::RunProperties.new
              formatter.call(run)
            end
            para << link
          end
        end

        def has_rich_children?(element)
          eo = element.element_order
          return false unless eo.is_a?(Array) && !eo.empty?

          eo.any? { |e| e.element? && e.name != "text" }
        end

        def render_subscript(element, para)
          if ordered?(element) && has_rich_children?(element)
            render_with_run_format(element, para) do |run|
              run.properties.vertical_align = Uniword::Properties::VerticalAlign.new(value: "subscript")
            end
            return
          end

          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).subscript
          para << run.build
        end

        def render_superscript(element, para)
          if ordered?(element) && has_rich_children?(element)
            render_with_run_format(element, para) do |run|
              run.properties.vertical_align = Uniword::Properties::VerticalAlign.new(value: "superscript")
            end
            return
          end

          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).superscript
          para << run.build
        end

        def render_monospace(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          # Era C: InlineCode character style for <tt>, <code>, etc.
          style = @resolver.character_style(:inline_code)
          if style
            add_text_with_char_style(para, text, style)
          else
            run = Uniword::Builder::RunBuilder.new
            run.text(text).font("Courier New")
            para << run.build
          end
        end

        def render_strikethrough(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).strike
          para << run.build
        end

        def render_underline(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).underline
          para << run.build
        end

        def render_keyword(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).bold.small_caps
          para << run.build
        end

        def render_smallcap(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).small_caps
          para << run.build
        end

        def render_link(element, para)
          text = collect_text(element)
          target = element.target

          if text.nil? || text.empty?
            text = target
            text = text.sub(/\Amailto:/, "") if text&.start_with?("mailto:")
          end
          return if text.nil? || text.empty?

          if target
            link = Uniword::Hyperlink.new(url: target, text: text)
            model = link.to_model(allocator: @doc.allocator)
            apply_hyperlink_style(model)
            para << model
          else
            run = Uniword::Builder::RunBuilder.new
            run.text(text).underline.color("0000FF")
            para << run.build
          end
        end

        def render_xref(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          target = element.target
          if target
            link = Uniword::Hyperlink.new(anchor: target, text: text)
            link_model = link.to_model(allocator: @doc.allocator)
            apply_hyperlink_style(link_model)
            para << link_model
          else
            run = Uniword::Builder::RunBuilder.new
            run.text(text).underline.color("0000FF")
            para << run.build
          end
        end

        def render_eref(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          cite = element.citeas || element.bibitemid
          if cite && !cite.empty?
            link = Uniword::Hyperlink.new(url: "##{cite}", text: text)
            link_model = link.to_model(allocator: @doc.allocator)
            apply_hyperlink_style(link_model)
            para << link_model
          else
            para << text
          end
        end

        def render_fmt_xref(element, para)
          target = element.target
          if target
            link_model = Uniword::Wordprocessingml::Hyperlink.new
            link_model.anchor = target

            temp = Uniword::Builder::ParagraphBuilder.new
            render_mixed_inline_fallback(element, temp)
            temp.model.runs.each { |r| link_model.runs << r }

            if link_model.runs.empty?
              text = collect_text(element)
              if text && !text.empty?
                run = Uniword::Wordprocessingml::Run.new(text: text)
                link_model.runs << run
              end
            end

            apply_hyperlink_style(link_model) unless link_model.runs.empty?
            para << link_model unless link_model.runs.empty?
          else
            render_mixed_inline_fallback(element, para)
          end
        end

        def render_footnote(element, para)
          cache_key = footnote_cache_key(element)
          if cache_key && @footnote_cache.key?(cache_key)
            id = @footnote_cache[cache_key]
            fn_run = Uniword::Wordprocessingml::Run.new(
              footnote_reference: Uniword::Wordprocessingml::FootnoteReference.new(id: id.to_s),
            )
            apply_run_char_style(fn_run, :footnote_reference)
            para << fn_run
            return
          end

          text = extract_footnote_text(element)
          return if text.nil? || text.empty?

          fn_run = build_footnote_with_style(text)
          fn_id = fn_run.footnote_reference&.id
          @footnote_cache[cache_key] = fn_id if cache_key && fn_id
          apply_run_char_style(fn_run, :footnote_reference)
          para << fn_run
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

        # Cache key is the source footnote identity (target → id → reference),
        # NOT the text. Two footnotes with the same text but different source
        # identities are distinct footnotes in OOXML.
        def footnote_cache_key(element)
          return element.target if element.class.attributes.key?(:target) && element.target
          return element.id if element.class.attributes.key?(:id) && element.id
          nil
        end

        def extract_footnote_text(element)
          p_children = element.p
          if p_children && !p_children.empty?
            return p_children.map { |p| collect_text(p) }.join(" ")
          end

          collect_all_text(element)
        end

        # Render a sourcecode callout as a superscript "(N)" run.
        # The callout's bare text (e.g., "1") is collected from its
        # element_order since Callout has no map_content on its class.
        def render_callout(element, para)
          text = collect_callout_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text("(#{text})").superscript
          para << run.build
        end

        def collect_callout_text(callout)
          segments = []
          each_ordered_element(callout) do |type, obj|
            segments << obj.to_s if type == :text
          end
          segments.join
        end

        def render_stem(element, para)
          text = stem_fallback_text(element)
          add_text_with_char_style(para, text, :stem) if text && !text.empty?
        rescue StandardError
          text = stem_fallback_text(element)
          add_text_with_char_style(para, text, :stem) if text && !text.empty?
        end

        def stem_fallback_text(element)
          if element.class.attributes.key?(:asciimath)
            am = element.asciimath
            return am if am.is_a?(String) && !am.empty?
          end
          collect_text(element)
        end

        def render_inline_image(element, para)
          src = element.source
          return unless src

          width = parse_dimension(element.width)
          height = parse_dimension(element.height)
          alt = element.alt

          begin
            if src.start_with?("data:")
              path = extract_data_uri_to_tempfile(src)
            elsif File.exist?(src)
              path = src
            else
              para << (alt || "[Image]")
              return
            end

            run = Uniword::Builder::ImageBuilder.create_run(
              @doc, path,
              width: width, height: height,
              alt_text: alt
            )
            para << run
          rescue StandardError
            para << (alt || "[Image]")
          end
        end

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

        # Apply a character style from the resolver by key name.
        def apply_run_char_style(run, style_key)
          style = @resolver.character_style(style_key)
          return unless style

          run.properties ||= Uniword::Wordprocessingml::RunProperties.new
          run.properties.style = Uniword::Properties::RunStyleReference.new(
            value: style,
          )
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

        def render_bookmark(element, para)
          name = element.id || element.name
          return unless name

          id = @context.next_bookmark_id.to_s
          para << Uniword::Wordprocessingml::BookmarkStart.new(id: id, name: name)
          para << Uniword::Wordprocessingml::BookmarkEnd.new(id: id)
        end

        def render_semx(element, para)
          return if @strip_autonum && element.element_attr.to_s == "autonum"

          case element.element_attr
          when "link"
            nil
          else
            render_mixed_inline_fallback(element, para)
          end
        end

        def render_mixed_inline_fallback(element, para)
          if ordered?(element)
            element.each_mixed_content do |child|
              case child
              when String then add_text(para, child)
              else render_inline_element(child, para)
              end
            end
          else
            text = collect_text(element)
            add_text(para, text) if text && !text.empty?
          end
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

            Array(val).each { |el| render_inline_element(el, para) }
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

        # Render a comment range start marker for the given annotation element.
        # The FmtAnnotationStartElement has a `target` attribute that maps to
        # the fmt-annotation-body ID, which CommentRenderer maps to a DOCX
        # comment ID.
        #
        # Note: CommentRangeStart/End markers are added to the paragraph's
        # element_order directly if the builder doesn't accept them via <<.
        def render_annotation_start(element, para)
          target_id = element.target if element.class.attributes.key?(:target)
          return unless target_id

          comment_id = lookup_comment_id(target_id)
          return unless comment_id

          marker = Uniword::Wordprocessingml::CommentRangeStart.new(id: comment_id)
          para << marker
        rescue ArgumentError
          # ParagraphBuilder doesn't accept this type — skip silently.
          # Comment definitions are still created in comments.xml.
          nil
        end

        # Render a comment range end marker and comment reference.
        def render_annotation_end(element, para)
          target_id = element.target if element.class.attributes.key?(:target)
          return unless target_id

          comment_id = lookup_comment_id(target_id)
          return unless comment_id

          end_marker = Uniword::Wordprocessingml::CommentRangeEnd.new(id: comment_id)
          para << end_marker

          ref_run = Uniword::Wordprocessingml::Run.new(
            comment_reference: Uniword::Wordprocessingml::CommentReference.new(
              id: comment_id,
            ),
          )
          apply_run_char_style(ref_run, :comment_reference)
          para << ref_run
        rescue ArgumentError
          nil
        end

        def lookup_comment_id(annotation_target_id)
          return nil unless @comment_id_lookup

          @comment_id_lookup.call(annotation_target_id)
        end
      end
    end
  end
end
